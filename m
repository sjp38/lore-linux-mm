Return-Path: <SRS0=ID2a=PJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 30C82C43612
	for <linux-mm@archiver.kernel.org>; Tue,  1 Jan 2019 00:44:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B519421720
	for <linux-mm@archiver.kernel.org>; Tue,  1 Jan 2019 00:44:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="tMXnz5Xz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B519421720
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 220A68E0005; Mon, 31 Dec 2018 19:44:37 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1D0BC8E0002; Mon, 31 Dec 2018 19:44:37 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 09AA68E0005; Mon, 31 Dec 2018 19:44:37 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id D6E118E0002
	for <linux-mm@kvack.org>; Mon, 31 Dec 2018 19:44:36 -0500 (EST)
Received: by mail-oi1-f198.google.com with SMTP id r131so19770755oia.7
        for <linux-mm@kvack.org>; Mon, 31 Dec 2018 16:44:36 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version;
        bh=3clf4p2zR0Kr6AYYOg+cEyz2yTDTor5Y/lT1dJ6upqE=;
        b=p3H2Di8QQtEya+Zv1lS7Hcjnm3LxokjRETaweIGXRkyHlG+EGYV/6QhPCIiLHJwqDD
         sodxt4HxevUHE0soIeVq7/EvGbGtfMl5S7kVaMcYaFcfHLaboeouqTZfYJE+0Js/yPSF
         JNuMbsZyF/ofe1o3dXprqLXn34Ra8jzzPctFqUXfQ1b630cIlhe+/8O4WKHPRoyusJfQ
         UZPEusAW4U3OrnpNDCYnjpO8V8bcMzU/gdUGEa9AhY2x2Enz5wqBgfynDB5gHUkxU5dl
         PGoM5PTbIBgNv7zJym+2iKCwF8l7cFpU5rHTmq+vB4HojiU2qkf2VdK/HLIHzu3u81D4
         d3mQ==
X-Gm-Message-State: AA+aEWZRWyON+d4SjlDlPIuH5IcHwFA2ox3mQl7xm5f0Ef4DZnBOuNzq
	MwlRkb7uSmfE72z/05zaP6P5RhBinO8L1axVLe9yDwS0TXAFRBm5SiVSkKtGeSncvPLzOIS/kfB
	XaePmYIZtK/Ihv7gfq5D1kMjuB3F3jzXFUvB2fTVY8OBUmXFqRJomW7mKRelStLgTY6Hfd8JQep
	aohQvjm0HxvP6jcAQQIMTuEiYmV+3Wbv/s+O5XWOm5fjVr+PNuSanHP7Jd03gXAk3I7NLljQ4TB
	sJ4rLuCxM4Vv3S/GeeQibMj/Kf7oqcb41tVjaAE74tqnN/Bqs4dpAXHsJQOMEE8E7rS/5xVaXVz
	ad+6cVWpTqL58ECi2mzAWX7su4uyceTaS8Y4q5xNYaS8TMFL3x1WwC6ypYq4XftrMYm99MF2Sp6
	C
X-Received: by 2002:aca:cc0d:: with SMTP id c13mr25470684oig.150.1546303476479;
        Mon, 31 Dec 2018 16:44:36 -0800 (PST)
X-Received: by 2002:aca:cc0d:: with SMTP id c13mr25470662oig.150.1546303475405;
        Mon, 31 Dec 2018 16:44:35 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546303475; cv=none;
        d=google.com; s=arc-20160816;
        b=LXkQiku7ZKJA3V8285206144nYV4tmg3S/BAFNQ51kTPFFLSKyzzNz1+BHr5EvsFNJ
         4bDZQ6Kuk2m/ezDtvLinz+VPJdQMBNgHvMtKdHBuKgyNyEo4/Ajc45KxEZpQOyQeIVIK
         YeovzZgj39QFfs4j1Fle3jjbqlK9//IIHS0Qz/qxLZT46nQd/Xi6SdLivl7hE/1Z8Gpf
         ddtlrc16N3k5iHby/oyg2z6lqGyBJS/J5EKM/a/xwYEwXE8f4p/sozMIePKQrEo8krBD
         Jg01amEeI59lGFmJCpXlKBIhjlqsmiLzMC/yBEhnuNOyhfybZQCG8gUQCrFaGcFU/H4t
         k3Zw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date:dkim-signature;
        bh=3clf4p2zR0Kr6AYYOg+cEyz2yTDTor5Y/lT1dJ6upqE=;
        b=kWP2x08O76Q0JSJq2u/j7qk4IGaOXMmN2YCAixx2OWbvZPCgrkNwsuUgj2C9DGL/xI
         p6l3cN7SbFQdZ32J4oU8pE2fQExM0XyEWG6g1m1QLPFDlIRrVox2pKBvlIkqWLOnkPQo
         Ze5XYfSs5e+VYvgwszz14XA1ATsMAoVWlbnLozGK0LJz8dRuYRPWN7RJ68tyUUl92EQD
         P1PFTtJJ1DWJszAxQVbb/+JnsOpCdzGUVuR5OCFP/doj9f557H8j1NN2avpVGo/zbam9
         JCdSrGnf5hdONxI4Dk1X8f4U3WB/N3NHefJXsTbeedyBezb6OP57QxQ4BGZ+BlYHLwSM
         q33g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=tMXnz5Xz;
       spf=pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=hughd@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s7sor18849967oic.155.2018.12.31.16.44.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 31 Dec 2018 16:44:35 -0800 (PST)
Received-SPF: pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=tMXnz5Xz;
       spf=pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=hughd@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=3clf4p2zR0Kr6AYYOg+cEyz2yTDTor5Y/lT1dJ6upqE=;
        b=tMXnz5Xz8WKhlJ0ckNW7G8rB3sE3qBwu8XJHbo/6WD8MB9JSNZfkmzQwX4j4kbscAH
         SWZZTgZQiV7sQcVT/S987wcIrjww6ttqifC+F8xBDfWSxyYlesy5pWJUoVIlm575Au2P
         HmQCgEQT4DRn9Jm+hdhnB7rBjShflNGsyGauRkwXJYga/L7meRCRjBvYqdjD6ReJwsBd
         uutvU2TAUt4QwEfoZ54QOrfrHgJUKVyAVZnIcYEysfGJEa6wBsJojOiXFaRCTKepGZEn
         nzqUKtyBHXCHAE3/P/X1Ie6cY6yqjuV7pT9O6xE0j8xaeqTzXs9f4CPZ/dnOTWFY22JL
         a++A==
X-Google-Smtp-Source: AFSGD/XImH2v0l15xE4/u4gjuTl0mDfvHSUDjdDkheK2WGTP+d6zwEHYJ9CremhKN+qt9LL4AIZ2dA==
X-Received: by 2002:a54:4486:: with SMTP id v6mr26570949oiv.233.1546303474701;
        Mon, 31 Dec 2018 16:44:34 -0800 (PST)
Received: from eggly.attlocal.net (172-10-233-147.lightspeed.sntcca.sbcglobal.net. [172.10.233.147])
        by smtp.gmail.com with ESMTPSA id c78sm37919044oig.30.2018.12.31.16.44.32
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 31 Dec 2018 16:44:33 -0800 (PST)
Date: Mon, 31 Dec 2018 16:44:24 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
X-X-Sender: hugh@eggly.anvils
To: Vineeth Remanan Pillai <vpillai@digitalocean.com>
cc: Matthew Wilcox <willy@infradead.org>, Hugh Dickins <hughd@google.com>, 
    Andrew Morton <akpm@linux-foundation.org>, 
    Huang Ying <ying.huang@intel.com>, linux-mm@kvack.org, 
    linux-kernel@vger.kernel.org, Kelley Nielsen <kelleynnn@gmail.com>, 
    Rik van Riel <riel@surriel.com>
Subject: Re: [PATCH v3 2/2] mm: rid swapoff of quadratic complexity
In-Reply-To: <20181203170934.16512-2-vpillai@digitalocean.com>
Message-ID: <alpine.LSU.2.11.1812311635590.4106@eggly.anvils>
References: <20181203170934.16512-1-vpillai@digitalocean.com> <20181203170934.16512-2-vpillai@digitalocean.com>
User-Agent: Alpine 2.11 (LSU 23 2013-08-11)
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190101004424.KLqQ5LpdR8TkZ9mjNj6itZucdRzAoTyjNkGdA_v4rZ0@z>

On Mon, 3 Dec 2018, Vineeth Remanan Pillai wrote:

> This patch was initially posted by Kelley(kelleynnn@gmail.com).
> Reposting the patch with all review comments addressed and with minor
> modifications and optimizations. Tests were rerun and commit message
> updated with new results.
> 
> The function try_to_unuse() is of quadratic complexity, with a lot of
> wasted effort. It unuses swap entries one by one, potentially iterating
> over all the page tables for all the processes in the system for each
> one.
> 
> This new proposed implementation of try_to_unuse simplifies its
> complexity to linear. It iterates over the system's mms once, unusing
> all the affected entries as it walks each set of page tables. It also
> makes similar changes to shmem_unuse.

Hi Vineeth, please fold in fixes below before reposting your
"mm,swap: rid swapoff of quadratic complexity" patch -
or ask for more detail if unclear.  I could split it up,
of course, but since they should all (except perhaps one)
just be merged into the base patch before going any further,
it'll save me time to keep them together here and just explain:-

shmem_unuse_swap_entries():
If a user fault races with swapoff, it's very normal for
shmem_swapin_page() to return -EEXIST, and the old code was
careful not to pass back any error but -ENOMEM; whereas on mmotm,
/usr/sbin/swapoff often failed silently because it got that EEXIST.

shmem_unuse():
A couple of crashing bugs there: a list_del_init without holding the
mutex, and too much faith in the "safe" in list_for_each_entry_safe():
it does assume that the mutex has been held throughout, you (very
nicely!) drop it, but that does require "next" to be re-evaluated.

shmem_writepage():
Not a bug fix, this is the "except perhaps one": minor optimization,
could be left out, but if shmem_unuse() is going through the list
in the forward direction, and may completely unswap a file and del
it from the list, then pages from that file can be swapped out to
*other* swap areas after that, and it be reinserted in the list:
better to reinsert it behind shmem_unuse()'s cursor than in front
of it, which would entail a second pointless pass over that file.

try_to_unuse():
Moved up the assignment of "oldi = i" (and changed the test to
"oldi <= i"), so as not to get trapped in that find_next_to_unuse()
loop when find_get_page() does not find it.

try_to_unuse():
But the main problem was passing entry.val to find_get_page() there:
that used to be correct, but since f6ab1f7f6b2d we need to pass just
the offset - as it stood, it could only find the pages when swapping
off area 0 (a similar issue was fixed in shmem_replace_page() recently).
That (together with the late oldi assignment) was why my swapoffs were
hanging on SWAP_HAS_CACHE swap_map entries.

With those changes, it all seems to work rather well, and is a nice
simplification of the source, in addition to removing the quadratic
complexity. To my great surprise, the KSM pages are already handled
fairly well - the ksm_might_need_to_copy() that has long been in
unuse_pte() turns out to do (almost) a good enough job already,
so most users of KSM and swapoff would never see any problem.
And I'd been afraid of swapin readahead causing spurious -ENOMEMs,
but have seen nothing of that in practice (though something else
in mmotm does appear to use up more memory than before).

My remaining criticisms would be:

As Huang Ying pointed out in other mail, there is a danger of
livelock (or rather, hitting the MAX_RETRIES limit) when a multiply
mapped page (most especially a KSM page, whose mappings are not
likely to be nearby in the mmlist) is swapped out then partially
swapped off then some ptes swapped back out.  As indeed the
"Under global memory pressure" comment admits.

I have hit the MAX_RETRIES 3 limit several times in load testing,
not investigated but I presume due to such a multiply mapped page,
so at present we do have a regression there.  A very simple answer
would be to remove the retries limiting - perhaps you just added
that to get around the find_get_page() failure before it was
understood?  That does then tend towards the livelock alternative,
but you've kept the signal_pending() check, so there's still the
same way out as the old technique had (but greater likelihood of
needing it with the new technique).  The right fix will be to do
an rmap walk to unuse all the swap entries of a single anon_vma
while holding page lock (with KSM needing that page force-deleted
from swap cache before moving on); but none of us have written
that code yet, maybe just removing the retries limit good enough.

Two dislikes on the code structure, probably one solution: the
"goto retry", up two levels from inside the lower loop, is easy to
misunderstand; and the oldi business is ugly - find_next_to_unuse()
was written to wrap around continuously to suit the old loop, but
now it's left with its "++i >= max" code to achieve that, then your
"i <= oldi" code to detect when it did, to undo that again: please
delete code from both ends to make that all simpler.

I'd expect to see checks on inuse_pages in some places, to terminate
the scans as soon as possible (swapoff of an unused swapfile should
be very quick, shouldn't it? not requiring any scans at all); but it
looks like the old code did not have those either - was inuse_pages
unreliable once upon a time? is it unreliable now?

Hugh

---

 mm/shmem.c    |   12 ++++++++----
 mm/swapfile.c |    8 ++++----
 2 files changed, 12 insertions(+), 8 deletions(-)

--- mmotm/mm/shmem.c	2018-12-22 13:32:51.339584848 -0800
+++ linux/mm/shmem.c	2018-12-31 12:30:55.822407154 -0800
@@ -1149,6 +1149,7 @@ static int shmem_unuse_swap_entries(stru
 		}
 		if (error == -ENOMEM)
 			break;
+		error = 0;
 	}
 	return error;
 }
@@ -1216,12 +1217,15 @@ int shmem_unuse(unsigned int type)
 		mutex_unlock(&shmem_swaplist_mutex);
 		if (prev_inode)
 			iput(prev_inode);
+		prev_inode = inode;
+
 		error = shmem_unuse_inode(inode, type);
-		if (!info->swapped)
-			list_del_init(&info->swaplist);
 		cond_resched();
-		prev_inode = inode;
+
 		mutex_lock(&shmem_swaplist_mutex);
+		next = list_next_entry(info, swaplist);
+		if (!info->swapped)
+			list_del_init(&info->swaplist);
 		if (error)
 			break;
 	}
@@ -1313,7 +1317,7 @@ static int shmem_writepage(struct page *
 	 */
 	mutex_lock(&shmem_swaplist_mutex);
 	if (list_empty(&info->swaplist))
-		list_add_tail(&info->swaplist, &shmem_swaplist);
+		list_add(&info->swaplist, &shmem_swaplist);
 
 	if (add_to_swap_cache(page, swap, GFP_ATOMIC) == 0) {
 		spin_lock_irq(&info->lock);
diff -purN mmotm/mm/swapfile.c linux/mm/swapfile.c
--- mmotm/mm/swapfile.c	2018-12-22 13:32:51.347584880 -0800
+++ linux/mm/swapfile.c	2018-12-31 12:30:55.822407154 -0800
@@ -2156,7 +2156,7 @@ retry:
 
 	while ((i = find_next_to_unuse(si, i, frontswap)) != 0) {
 		/*
-		 * under global memory pressure, swap entries
+		 * Under global memory pressure, swap entries
 		 * can be reinserted back into process space
 		 * after the mmlist loop above passes over them.
 		 * This loop will then repeat fruitlessly,
@@ -2164,7 +2164,7 @@ retry:
 		 * but doing nothing to actually free up the swap.
 		 * In this case, go over the mmlist loop again.
 		 */
-		if (i < oldi) {
+		if (i <= oldi) {
 			retries++;
 			if (retries > MAX_RETRIES) {
 				retval = -EBUSY;
@@ -2172,8 +2172,9 @@ retry:
 			}
 			goto retry;
 		}
+		oldi = i;
 		entry = swp_entry(type, i);
-		page = find_get_page(swap_address_space(entry), entry.val);
+		page = find_get_page(swap_address_space(entry), i);
 		if (!page)
 			continue;
 
@@ -2188,7 +2189,6 @@ retry:
 		try_to_free_swap(page);
 		unlock_page(page);
 		put_page(page);
-		oldi = i;
 	}
 out:
 	return retval;

