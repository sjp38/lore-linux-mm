Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3BC2C6B0038
	for <linux-mm@kvack.org>; Sun,  4 Dec 2016 18:31:12 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id y205so252873577qkb.4
        for <linux-mm@kvack.org>; Sun, 04 Dec 2016 15:31:12 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t6si7723424qtd.12.2016.12.04.15.31.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 04 Dec 2016 15:31:11 -0800 (PST)
Message-ID: <1480894267.3781.1.camel@redhat.com>
Subject: Re: [vfs:work.autofs 6/10] ERROR: "path_is_mountpoint"
 [fs/autofs4/autofs4.ko] undefined!
From: Ian Kent <ikent@redhat.com>
Date: Mon, 05 Dec 2016 07:31:07 +0800
In-Reply-To: <20161204152308.GF1555@ZenIV.linux.org.uk>
References: <201612040921.wXtI5ecC%fengguang.wu@intel.com>
	 <1480843688.7509.3.camel@redhat.com>
	 <20161204152308.GF1555@ZenIV.linux.org.uk>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: kbuild-all@01.org, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

On Sun, 2016-12-04 at 15:23 +0000, Al Viro wrote:
> On Sun, Dec 04, 2016 at 05:28:08PM +0800, Ian Kent wrote:
> 
> > 
> > Oh wait, I did see this when I looked at vfs.git#work.autofs but was more
> > concerned with the substance of the changes to pay attention to it.
> > 
> > That would be caused by:
> > bool path_is_mountpoint(const struct path *path)
> > {
> > ...
> > }
> > EXPORT_SYMBOL(__path_is_mountpoint);
> Had been fixed and pushed yesterday.

I missed it when I built my test kernel because I compile in the autofs module,
;)

Ian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
