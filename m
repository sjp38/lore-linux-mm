Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6EE2E6B0069
	for <linux-mm@kvack.org>; Sun,  4 Dec 2016 10:23:16 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id u144so10232720wmu.1
        for <linux-mm@kvack.org>; Sun, 04 Dec 2016 07:23:16 -0800 (PST)
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [195.92.253.2])
        by mx.google.com with ESMTPS id n1si11895813wjf.235.2016.12.04.07.23.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 04 Dec 2016 07:23:14 -0800 (PST)
Date: Sun, 4 Dec 2016 15:23:08 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [vfs:work.autofs 6/10] ERROR: "path_is_mountpoint"
 [fs/autofs4/autofs4.ko] undefined!
Message-ID: <20161204152308.GF1555@ZenIV.linux.org.uk>
References: <201612040921.wXtI5ecC%fengguang.wu@intel.com>
 <1480843688.7509.3.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1480843688.7509.3.camel@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ian Kent <ikent@redhat.com>
Cc: kbuild-all@01.org, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

On Sun, Dec 04, 2016 at 05:28:08PM +0800, Ian Kent wrote:

> Oh wait, I did see this when I looked at vfs.git#work.autofs but was more
> concerned with the substance of the changes to pay attention to it.
> 
> That would be caused by:
> bool path_is_mountpoint(const struct path *path)
> {
> ...
> }
> EXPORT_SYMBOL(__path_is_mountpoint);

Had been fixed and pushed yesterday.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
