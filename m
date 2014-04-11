Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f45.google.com (mail-la0-f45.google.com [209.85.215.45])
	by kanga.kvack.org (Postfix) with ESMTP id 1C8026B0035
	for <linux-mm@kvack.org>; Fri, 11 Apr 2014 02:10:05 -0400 (EDT)
Received: by mail-la0-f45.google.com with SMTP id hr17so3118192lab.18
        for <linux-mm@kvack.org>; Thu, 10 Apr 2014 23:10:04 -0700 (PDT)
Received: from plane.gmane.org (plane.gmane.org. [80.91.229.3])
        by mx.google.com with ESMTPS id sz4si4676559lbb.162.2014.04.10.23.10.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 10 Apr 2014 23:10:03 -0700 (PDT)
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glkm-linux-mm-2@m.gmane.org>)
	id 1WYUf2-0005JF-G5
	for linux-mm@kvack.org; Fri, 11 Apr 2014 08:10:00 +0200
Received: from 66-87-112-120.pools.spcsdns.net ([66.87.112.120])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Fri, 11 Apr 2014 08:10:00 +0200
Received: from eternaleye by 66-87-112-120.pools.spcsdns.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Fri, 11 Apr 2014 08:10:00 +0200
From: Alex Elsayed <eternaleye@gmail.com>
Subject: Re: [PATCH 0/6] File Sealing & memfd_create()
Date: Thu, 10 Apr 2014 23:09:46 -0700
Message-ID: <li80vb$n3m$2@ger.gmane.org>
References: <1395256011-2423-1-git-send-email-dh.herrmann@gmail.com> <20140320153250.GC20618@thunk.org> <1397141388.16343.10@mail.messagingengine.com> <5346EDE8.2060004@amacapital.net> <1397159378.4434.1@mail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7Bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-fsdevel@vger.kernel.org

Colin Walters wrote:

> On Thu, Apr 10, 2014 at 3:15 PM, Andy Lutomirski <luto@amacapital.net>
> wrote:
>> 
>> 
>> COW links can do this already, I think.  Of course, you'll have to
>> use a
>> filesystem that supports them.
> 
> COW is nice if the filesystem supports them, but my userspace code
> needs to be filesystem agnostic.  Because of that, the design for
> userspace simply doesn't allow arbitrary writes.
> 
> Instead, I have to painfully audit every rpm %post/dpkg postinst type
> script to ensure they break hardlinks, and furthermore only allow
> executing scripts that are known to do so.
> 
> But I think even in a btrfs world it'd still be useful to mark files as
> content-immutable.

If you create each tree as a subvolume and when it's complete put it in 
place with btrfs subvolume snapshot -r FOO_inprogress /ostree/repo/FOO,
you get exactly that.

You can even use the new(ish) btrfs out-of-band dedup functionality to 
deduplicate read-only snapshots safely.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
