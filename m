Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 54F276B0069
	for <linux-mm@kvack.org>; Sun,  4 Dec 2016 04:28:14 -0500 (EST)
Received: by mail-qt0-f197.google.com with SMTP id l20so202037728qta.3
        for <linux-mm@kvack.org>; Sun, 04 Dec 2016 01:28:14 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k6si6743228qkf.38.2016.12.04.01.28.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 04 Dec 2016 01:28:13 -0800 (PST)
Message-ID: <1480843688.7509.3.camel@redhat.com>
Subject: Re: [vfs:work.autofs 6/10] ERROR: "path_is_mountpoint"
 [fs/autofs4/autofs4.ko] undefined!
From: Ian Kent <ikent@redhat.com>
Date: Sun, 04 Dec 2016 17:28:08 +0800
In-Reply-To: <201612040921.wXtI5ecC%fengguang.wu@intel.com>
References: <201612040921.wXtI5ecC%fengguang.wu@intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: kbuild-all@01.org, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

On Sun, 2016-12-04 at 09:04 +0800, kbuild test robot wrote:
> tree:A A A https://git.kernel.org/pub/scm/linux/kernel/git/viro/vfs.git
> work.autofs
> head:A A A 75aa916747375486b99966e78755a382f432d63c
> commit: fee9da65299be1a18829334b6f74d7dd4d688248 [6/10] autofs: use
> path_is_mountpoint() to fix unreliable d_mountpoint() checks
> config: x86_64-randconfig-i0-201649 (attached as .config)
> compiler: gcc-4.9 (Debian 4.9.4-2) 4.9.4
> reproduce:
> A A A A A A A A git checkout fee9da65299be1a18829334b6f74d7dd4d688248
> A A A A A A A A # save the attached .config to linux build tree
> A A A A A A A A make ARCH=x86_64A 
> 
> All errors (new ones prefixed by >>):
> 
> > 
> > > 
> > > ERROR: "path_is_mountpoint" [fs/autofs4/autofs4.ko] undefined!

Oh wait, I did see this when I looked at vfs.git#work.autofs but was more
concerned with the substance of the changes to pay attention to it.

That would be caused by:
bool path_is_mountpoint(const struct path *path)
{
...
}
EXPORT_SYMBOL(__path_is_mountpoint);

Ian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
