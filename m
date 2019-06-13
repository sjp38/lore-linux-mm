Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 16559C31E46
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 00:04:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BABD021721
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 00:04:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="PwhK9KDI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BABD021721
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 335206B0008; Wed, 12 Jun 2019 20:04:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2E5816B000E; Wed, 12 Jun 2019 20:04:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1D5C56B0010; Wed, 12 Jun 2019 20:04:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id DBB726B0008
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 20:04:32 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id f9so13145642pfn.6
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 17:04:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=IcswwZUgsj7YUPNnNhWKtBIpylsIv3CV5VizTq8ogT4=;
        b=MRkA2rRJoaXApcyjUIav4gM+b5nyAgvLUYhgYHrGSD1Jms0BQeeeKanyP2DOT7XRGS
         gOX3eG2vMd4fbZ4sDcPDP4OnAsMOca4mMGcNslwuZG6zQWkCljnj6857UyuxRm3d9XFF
         OB6dF0YrZyvIgJ92CXoZAaXigJXsLGtwM3o8c3+EgjqZndCljgso1ppKVJmXnca1TE3k
         1omH6mNbuiXW+T7hRNciCs2Gy2JvEvADRREKH/BmyDzvoJhtLvHKsyqwYkT6JsTllKPr
         hsVMGRx1/rj0HID9/SQOBWqGwDoiwcKg470vhZNYVwIlhhZLeOaDBuLDj2K4pkooAOjg
         ttOQ==
X-Gm-Message-State: APjAAAXsWvjxT9M2OatoQofIVqia80tPwZNZVT3ofymOu9UP+NAvP/1/
	2fMBEFWncSciBI9+XseXgmLGcNwtaCbE9MdDilh8Swo1Inl1PWiRmLSFFUy3UYIqCq4e/+1vbbo
	zIXn3g+vIXjeNJ6/mkFfdkv3h7MrtMBvufQo+seQpbp0rj6bwJ0/PBMgOh36e4yk9wQ==
X-Received: by 2002:a17:90a:1b0c:: with SMTP id q12mr1824260pjq.76.1560384272488;
        Wed, 12 Jun 2019 17:04:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyKBjU9hWQxdBW6nT2Zs0LAIluf6tEYK2Bzswf0Ws1qGI0THCf+6JNfmN6YI0hhaVO1BNAF
X-Received: by 2002:a17:90a:1b0c:: with SMTP id q12mr1824219pjq.76.1560384271734;
        Wed, 12 Jun 2019 17:04:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560384271; cv=none;
        d=google.com; s=arc-20160816;
        b=1DOyj1dulVV7lGx74GfdIY2ShhoC2c2l6WVsAvGWd/MA1tvVQ1Vsvcd2I8JEvJ3Bxs
         nBOU27ZnjBpX1W2WXEpMFciDe6QYZrXIrPeoLK6Elqz8/SFj2elhm8CBDLIyvIpLLNx2
         UczRN6jdVnmclmCBgFDDj7Ja3WEKzoSYtTYe8k2a0kWtlMT1wgcj4J0X4hs0GMN71Iui
         8/xqRRYRSHWMOpLlx94HPag/Uj6An+LPtOc9SRRpHcIbmGbvcjG/OceMjMs9rJQpbA9x
         1RO1L8qO1yo+vmTdN9hJ+7nnVzq1jZD5Y5CY9MFbixMmR2n0WjoxlSWBviHrDsd+0cKo
         Jywg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=IcswwZUgsj7YUPNnNhWKtBIpylsIv3CV5VizTq8ogT4=;
        b=Wg4IutSuOEhZhxNNZkGlgJ3s+h0oR0lpTZCniJBZByYBbDEoH9o0g6UMZfLbB/ecrs
         h3XD6Ruyaf8EggyI6RVuvl1YlbCm+o7kcfxlm0eg/jHqS8A5iN7PHVtkRLnR3JS8y6pF
         oH/pIv0qbSk/hFAd0HqylJiqqzkK299myUewNaabloo5whaRo6tqzm3CvB2fHwNmckEh
         m657qkFP0tDEQDWidzWFavisl5dKs6REMk0588eiO3y03dsW4GmJo7pW+ciyvWnQbTFA
         tJHxEhePX/VWC/QXKvnUzwmEULARUE4P6TjDMZmSYAaUmkUv/8tBq2eOTnZg9lKWvodf
         tnYw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=PwhK9KDI;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id b40si978438pla.49.2019.06.12.17.04.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Jun 2019 17:04:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=PwhK9KDI;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 8381A215EA;
	Thu, 13 Jun 2019 00:04:29 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1560384270;
	bh=NTkyzDj/QTOLghrPG/JLDkCzWtcmWPclnCXZ6csi8dA=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=PwhK9KDIoVeC2KXyMTN6hRechTgZcxmHUKfC6o0xKoyJM52N4EE9Tk90KuatIgf9i
	 3X905okdRCZm9quqBHQxd1WrrwOO1YuXMgfgt3pkNwWDgP6kbVmVhXk3xT+PbA37ho
	 198aMxiCu+sXlojynnQhbEz6gXddsNXhRzs7LkF4=
Date: Wed, 12 Jun 2019 17:04:29 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Andrei Vagin <avagin@gmail.com>
Cc: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, Oleg Nesterov <oleg@redhat.com>, Matthew
 Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Cyrill
 Gorcunov <gorcunov@gmail.com>, Kirill Tkhai <ktkhai@virtuozzo.com>, Michal
 =?ISO-8859-1?Q?Koutn=FD?= <mkoutny@suse.com>, Al Viro
 <viro@zeniv.linux.org.uk>, Roman Gushchin <guro@fb.com>, Dmitry Safonov
 <dima@arista.com>
Subject: Re: [PATCH v2 5/6] proc: use down_read_killable mmap_sem for
 /proc/pid/map_files
Message-Id: <20190612170429.baaae5fe6d84b864508a3ec5@linux-foundation.org>
In-Reply-To: <20190612231426.GA3639@gmail.com>
References: <156007465229.3335.10259979070641486905.stgit@buzz>
	<156007493995.3335.9595044802115356911.stgit@buzz>
	<20190612231426.GA3639@gmail.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 12 Jun 2019 16:14:28 -0700 Andrei Vagin <avagin@gmail.com> wrote:

> On Sun, Jun 09, 2019 at 01:09:00PM +0300, Konstantin Khlebnikov wrote:
> > Do not stuck forever if something wrong.
> > Killable lock allows to cleanup stuck tasks and simplifies investigation.
> 
> This patch breaks the CRIU project, because stat() returns EINTR instead
> of ENOENT:
> 
> [root@fc24 criu]# stat /proc/self/map_files/0-0
> stat: cannot stat '/proc/self/map_files/0-0': Interrupted system call
> 
> Here is one inline comment with the fix for this issue.
> 
> > @@ -2107,7 +2113,10 @@ static struct dentry *proc_map_files_lookup(struct inode *dir,
> >  	if (!mm)
> >  		goto out_put_task;
> >  
> > -	down_read(&mm->mmap_sem);
> > +	result = ERR_PTR(-EINTR);
> > +	if (down_read_killable(&mm->mmap_sem))
> > +		goto out_put_mm;
> > +
> 
> 	result = ERR_PTR(-ENOENT);
> 

yes, thanks.

--- a/fs/proc/base.c~proc-use-down_read_killable-mmap_sem-for-proc-pid-map_files-fix
+++ a/fs/proc/base.c
@@ -2117,6 +2117,7 @@ static struct dentry *proc_map_files_loo
 	if (down_read_killable(&mm->mmap_sem))
 		goto out_put_mm;
 
+	result = ERR_PTR(-ENOENT);
 	vma = find_exact_vma(mm, vm_start, vm_end);
 	if (!vma)
 		goto out_no_vma;



We started doing this trick of using

	ret = -EFOO;
	if (something)
		goto out;

decades ago because it generated slightly better code.  I rather doubt
whether that's still the case.

In fact this:

--- a/fs/proc/base.c~a
+++ a/fs/proc/base.c
@@ -2096,35 +2096,45 @@ static struct dentry *proc_map_files_loo
 	struct dentry *result;
 	struct mm_struct *mm;
 
-	result = ERR_PTR(-ENOENT);
 	task = get_proc_task(dir);
-	if (!task)
+	if (!task) {
+		result = ERR_PTR(-ENOENT);
 		goto out;
+	}
 
-	result = ERR_PTR(-EACCES);
-	if (!ptrace_may_access(task, PTRACE_MODE_READ_FSCREDS))
+	if (!ptrace_may_access(task, PTRACE_MODE_READ_FSCREDS)) {
+		result = ERR_PTR(-EACCES);
 		goto out_put_task;
+	}
 
-	result = ERR_PTR(-ENOENT);
-	if (dname_to_vma_addr(dentry, &vm_start, &vm_end))
+	if (dname_to_vma_addr(dentry, &vm_start, &vm_end)) {
+		result = ERR_PTR(-ENOENT);
 		goto out_put_task;
+	}
 
 	mm = get_task_mm(task);
-	if (!mm)
+	if (!mm) {
+		result = ERR_PTR(-ENOENT);
 		goto out_put_task;
+	}
 
-	result = ERR_PTR(-EINTR);
-	if (down_read_killable(&mm->mmap_sem))
+	if (down_read_killable(&mm->mmap_sem)) {
+		result = ERR_PTR(-EINTR);
 		goto out_put_mm;
+	}
 
-	result = ERR_PTR(-ENOENT);
 	vma = find_exact_vma(mm, vm_start, vm_end);
-	if (!vma)
+	if (!vma) {
+		result = ERR_PTR(-ENOENT);
 		goto out_no_vma;
+	}
 
-	if (vma->vm_file)
+	if (vma->vm_file) {
 		result = proc_map_files_instantiate(dentry, task,
 				(void *)(unsigned long)vma->vm_file->f_mode);
+	} else {
+		result = ERR_PTR(-ENOENT);
+	}
 
 out_no_vma:
 	up_read(&mm->mmap_sem);

makes no change to the generated assembly with gcc-7.2.0.

And I do think that the above style is clearer and more reliable, as
this bug demonstrates.

