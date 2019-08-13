Return-Path: <SRS0=aN9C=WJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DF565C433FF
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 15:30:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 82FC72084D
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 15:30:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=joelfernandes.org header.i=@joelfernandes.org header.b="Cdj2X0H1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 82FC72084D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=joelfernandes.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 28BDE6B0005; Tue, 13 Aug 2019 11:30:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2159C6B0007; Tue, 13 Aug 2019 11:30:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0DD286B0008; Tue, 13 Aug 2019 11:30:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0094.hostedemail.com [216.40.44.94])
	by kanga.kvack.org (Postfix) with ESMTP id D8CBE6B0005
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 11:30:24 -0400 (EDT)
Received: from smtpin17.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 7F9708248AA1
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 15:30:24 +0000 (UTC)
X-FDA: 75817791168.17.rule89_2089275898f4f
X-HE-Tag: rule89_2089275898f4f
X-Filterd-Recvd-Size: 11406
Received: from mail-pl1-f193.google.com (mail-pl1-f193.google.com [209.85.214.193])
	by imf34.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 15:30:23 +0000 (UTC)
Received: by mail-pl1-f193.google.com with SMTP id ay6so49483160plb.9
        for <linux-mm@kvack.org>; Tue, 13 Aug 2019 08:30:23 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=joelfernandes.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=LKZJWtoWyWG5oxOm0+yUDXsQTGCyVoWJLlMAumAfqVk=;
        b=Cdj2X0H1Yse9eA+Td/DY9JIndyhgdmD87pLz6SjLZTyJP1uBHk7IkGYh7fc3ZuMMcW
         VhZs53HifLCOjUiexLisADVqi8ni23lvgD94h8kRcYcbTuZn7Qgtf5NGHLhqILTgCEm5
         5gkOrwR3dWK6jyxnae5MPATeQDCe9PffHXxYc=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=LKZJWtoWyWG5oxOm0+yUDXsQTGCyVoWJLlMAumAfqVk=;
        b=QBR+a5HZgp+hxFXYllFkFiwceBo7xW+zWMLgTR7umyvqAgIBP292NtJkUp8IJhaJIt
         jJ2b/DYsT/ONsyAeGN0w69YcMAz5kV4sz1Z5dwUfA0mA+P44SIVXpu/BfadbE00nINP3
         PUy0L82vPkVBxYakyCBFX6pmz5lTX4ERQZmhPySMlZ1pMcBZb6cfGKzbe6jXev1WrZhO
         8PlYO0wr0llVwtYOsnDWXKcW3a194oF3Dt8L4ekXnkuPFtwgIgEId+kq3iOOmd2+aCXK
         LNmLnWQDwnRb4s9Yu1MZ7Z84wUsP8gsBYmYYNo0dl+0ujfrCodfPm3rNvexhUiRnbAen
         gjEA==
X-Gm-Message-State: APjAAAUpa0cGpRa53HLjS7jDD2F07e4pm3oIbAaHlLlxX2fH8eTgz6y1
	QPGPD5LgeRmSJ2bQX3mdD/I1+w==
X-Google-Smtp-Source: APXvYqyyFJ/TRIiPoznYFZ5GRhe5I4cJo1AfaIwTrvJcDh2aWhHM5FAN95mujqC58WgWlcLX0Mc0tA==
X-Received: by 2002:a17:902:461:: with SMTP id 88mr27248372ple.296.1565710222196;
        Tue, 13 Aug 2019 08:30:22 -0700 (PDT)
Received: from localhost ([2620:15c:6:12:9c46:e0da:efbf:69cc])
        by smtp.gmail.com with ESMTPSA id k5sm10597088pgo.45.2019.08.13.08.30.20
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 13 Aug 2019 08:30:21 -0700 (PDT)
Date: Tue, 13 Aug 2019 11:30:20 -0400
From: Joel Fernandes <joel@joelfernandes.org>
To: Jann Horn <jannh@google.com>
Cc: kernel list <linux-kernel@vger.kernel.org>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Borislav Petkov <bp@alien8.de>, Brendan Gregg <bgregg@netflix.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Christian Hansen <chansen3@cisco.com>,
	Daniel Colascione <dancol@google.com>, fmayer@google.com,
	"H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>,
	Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>,
	kernel-team <kernel-team@android.com>,
	Linux API <linux-api@vger.kernel.org>, linux-doc@vger.kernel.org,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	Linux-MM <linux-mm@kvack.org>, Michal Hocko <mhocko@suse.com>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Minchan Kim <minchan@kernel.org>, namhyung@google.com,
	"Paul E. McKenney" <paulmck@linux.ibm.com>,
	Robin Murphy <robin.murphy@arm.com>, Roman Gushchin <guro@fb.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	Suren Baghdasaryan <surenb@google.com>,
	Thomas Gleixner <tglx@linutronix.de>, Todd Kjos <tkjos@google.com>,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	Vlastimil Babka <vbabka@suse.cz>, Will Deacon <will@kernel.org>
Subject: Re: [PATCH v5 1/6] mm/page_idle: Add per-pid idle page tracking
 using virtual index
Message-ID: <20190813153020.GC14622@google.com>
References: <20190807171559.182301-1-joel@joelfernandes.org>
 <CAG48ez0ysprvRiENhBkLeV9YPTN_MB18rbu2HDa2jsWo5FYR8g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAG48ez0ysprvRiENhBkLeV9YPTN_MB18rbu2HDa2jsWo5FYR8g@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 12, 2019 at 08:14:38PM +0200, Jann Horn wrote:
[snip] 
> > +/* Helper to get the start and end frame given a pos and count */
> > +static int page_idle_get_frames(loff_t pos, size_t count, struct mm_struct *mm,
> > +                               unsigned long *start, unsigned long *end)
> > +{
> > +       unsigned long max_frame;
> > +
> > +       /* If an mm is not given, assume we want physical frames */
> > +       max_frame = mm ? (mm->task_size >> PAGE_SHIFT) : max_pfn;
> > +
> > +       if (pos % BITMAP_CHUNK_SIZE || count % BITMAP_CHUNK_SIZE)
> > +               return -EINVAL;
> > +
> > +       *start = pos * BITS_PER_BYTE;
> > +       if (*start >= max_frame)
> > +               return -ENXIO;
> > +
> > +       *end = *start + count * BITS_PER_BYTE;
> > +       if (*end > max_frame)
> > +               *end = max_frame;
> > +       return 0;
> > +}
> 
> You could add some overflow checks for the multiplications. I haven't
> seen any place where it actually matters, but it seems unclean; and in
> particular, on a 32-bit architecture where the maximum user address is
> very high (like with a 4G:4G split), it looks like this function might
> theoretically return with `*start > *end`, which could be confusing to
> callers.

I could store the multiplication result in unsigned long long (since we are
bounds checking with max_frame, start > end would not occur). Something like
the following (with extraneous casts). But I'll think some more about the
point you are raising.

diff --git a/mm/page_idle.c b/mm/page_idle.c
index 1ea21bbb36cb..8fd7a5559986 100644
--- a/mm/page_idle.c
+++ b/mm/page_idle.c
@@ -135,6 +135,7 @@ static int page_idle_get_frames(loff_t pos, size_t count, struct mm_struct *mm,
 				unsigned long *start, unsigned long *end)
 {
 	unsigned long max_frame;
+	unsigned long long tmp;
 
 	/* If an mm is not given, assume we want physical frames */
 	max_frame = mm ? (mm->task_size >> PAGE_SHIFT) : max_pfn;
@@ -142,13 +143,16 @@ static int page_idle_get_frames(loff_t pos, size_t count, struct mm_struct *mm,
 	if (pos % BITMAP_CHUNK_SIZE || count % BITMAP_CHUNK_SIZE)
 		return -EINVAL;
 
-	*start = pos * BITS_PER_BYTE;
-	if (*start >= max_frame)
+	tmp = pos * BITS_PER_BYTE;
+	if (tmp >= (unsigned long long)max_frame)
 		return -ENXIO;
+	*start = (unsigned long)tmp;
 
-	*end = *start + count * BITS_PER_BYTE;
-	if (*end > max_frame)
+	tmp = *start + count * BITS_PER_BYTE;
+	if (tmp > (unsigned long long)max_frame)
 		*end = max_frame;
+	else
+		*end = (unsigned long)tmp;
 	return 0;
 }
 
> [...]
> >         for (; pfn < end_pfn; pfn++) {
> >                 bit = pfn % BITMAP_CHUNK_BITS;
> >                 if (!bit)
> >                         *out = 0ULL;
> > -               page = page_idle_get_page(pfn);
> > -               if (page) {
> > -                       if (page_is_idle(page)) {
> > -                               /*
> > -                                * The page might have been referenced via a
> > -                                * pte, in which case it is not idle. Clear
> > -                                * refs and recheck.
> > -                                */
> > -                               page_idle_clear_pte_refs(page);
> > -                               if (page_is_idle(page))
> > -                                       *out |= 1ULL << bit;
> > -                       }
> > +               page = page_idle_get_page_pfn(pfn);
> > +               if (page && page_idle_pte_check(page)) {
> > +                       *out |= 1ULL << bit;
> >                         put_page(page);
> >                 }
> 
> The `page && !page_idle_pte_check(page)` case looks like it's missing
> a put_page(); you probably intended to write something like this?
> 
>     page = page_idle_get_page_pfn(pfn);
>     if (page) {
>         if (page_idle_pte_check(page))
>             *out |= 1ULL << bit;
>         put_page(page);
>     }

Ah, you're right. Will fix, good eyes and thank you!

> [...]
> > +/*  page_idle tracking for /proc/<pid>/page_idle */
> > +
> > +struct page_node {
> > +       struct page *page;
> > +       unsigned long addr;
> > +       struct list_head list;
> > +};
> > +
> > +struct page_idle_proc_priv {
> > +       unsigned long start_addr;
> > +       char *buffer;
> > +       int write;
> > +
> > +       /* Pre-allocate and provide nodes to pte_page_idle_proc_add() */
> > +       struct page_node *page_nodes;
> > +       int cur_page_node;
> > +       struct list_head *idle_page_list;
> > +};
> 
> A linked list is a weird data structure to use if the list elements
> are just consecutive array elements.

Not all of the pages will be considered in the later parts of the code, some
pages are skipped.

However, in v4 I added an array to allocate all the page_node structures,
since Andrew did not want GFP_ATOMIC allocations of individual list nodes.

So I think I could get rid of the linked list and leave the unused
page_node(s) as NULL, but I don't know I have to check if that is possible. I
could be missing a corner case, regardless I'll make a note of this and try!

> > +/*
> > + * Add page to list to be set as idle later.
> > + */
> > +static void pte_page_idle_proc_add(struct page *page,
> > +                              unsigned long addr, struct mm_walk *walk)
> > +{
> > +       struct page *page_get = NULL;
> > +       struct page_node *pn;
> > +       int bit;
> > +       unsigned long frames;
> > +       struct page_idle_proc_priv *priv = walk->private;
> > +       u64 *chunk = (u64 *)priv->buffer;
> > +
> > +       if (priv->write) {
> > +               VM_BUG_ON(!page);
> > +
> > +               /* Find whether this page was asked to be marked */
> > +               frames = (addr - priv->start_addr) >> PAGE_SHIFT;
> > +               bit = frames % BITMAP_CHUNK_BITS;
> > +               chunk = &chunk[frames / BITMAP_CHUNK_BITS];
> > +               if (((*chunk >> bit) & 1) == 0)
> > +                       return;
> 
> This means that BITMAP_CHUNK_SIZE is UAPI on big-endian systems,
> right? My opinion is that it would be slightly nicer to design the
> UAPI such that incrementing virtual addresses are mapped to
> incrementing offsets in the buffer (iow, either use bytewise access or
> use little-endian), but I'm not going to ask you to redesign the UAPI
> this late.

That would also be slow and consume more memory in userspace buffers.
Currently, a 64-bit (8 byte) chunk accounts for 64 pages worth or 256KB.

Also I wanted to keep the interface consistent with the global
/sys/kernel/mm/page_idle interface.

> [...]
> > +ssize_t page_idle_proc_generic(struct file *file, char __user *ubuff,
> > +                              size_t count, loff_t *pos, int write)
> > +{
> [...]
> > +       down_read(&mm->mmap_sem);
> [...]
> > +
> > +       if (!write && !walk_error)
> > +               ret = copy_to_user(ubuff, buffer, count);
> > +
> > +       up_read(&mm->mmap_sem);
> 
> I'd move the up_read() above the copy_to_user(); copy_to_user() can
> block, and there's no reason to hold the mmap_sem across
> copy_to_user().

Will do.

> Sorry about only chiming in at v5 with all this.

No problem, I'm glad you did!

thanks,

 - Joel


