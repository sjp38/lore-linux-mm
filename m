Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id DCF9B6B0031
	for <linux-mm@kvack.org>; Thu, 18 Jul 2013 20:00:36 -0400 (EDT)
Message-ID: <51E88176.6040505@zytor.com>
Date: Thu, 18 Jul 2013 16:59:50 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/5] initmpfs v2: use tmpfs instead of ramfs for rootfs
References: <20130715140135.0f896a584fec9f7861049b64@linux-foundation.org> <20130717160602.4b225ac80b1cb6121cbb489c@linux-foundation.org>
In-Reply-To: <20130717160602.4b225ac80b1cb6121cbb489c@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rob Landley <rob@landley.net>, linux-kernel@vger.kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>, "Eric W. Biederman" <ebiederm@xmission.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Hugh Dickins <hughd@google.com>, Jeff Layton <jlayton@redhat.com>, Jens Axboe <axboe@kernel.dk>, Jim Cromie <jim.cromie@gmail.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Rusty Russell <rusty@rustcorp.com.au>, Sam Ravnborg <sam@ravnborg.org>, Stephen Warren <swarren@nvidia.com>

On 07/17/2013 04:06 PM, Andrew Morton wrote:
> On Tue, 16 Jul 2013 08:31:13 -0700 (PDT) Rob Landley <rob@landley.net> wrote:
> 
>> Use tmpfs for rootfs when CONFIG_TMPFS=y and there's no root=.
>> Specify rootfstype=ramfs to get the old initramfs behavior.
>>
>> The previous initramfs code provided a fairly crappy root filesystem:
>> didn't let you --bind mount directories out of it, reported zero
>> size/usage so it didn't show up in "df" and couldn't run things like
>> rpm that query available space before proceeding, would fill up all
>> available memory and panic the system if you wrote too much to it...
> 
> The df problem and the mount --bind thing are ramfs issues, are they
> not?  Can we fix them?  If so, that's a less intrusive change, and we
> also get a fixed ramfs.
> 

mount --bind might be useful to fix for ramfs in general (as ramfs
should provide minimal standard filesystem functionality, and that one
counts, I believe), but honestly... we should have had tmpfs as a root
filesystem option either as rootfs or as an automatic overmount a long
time ago.

The automatic overmount option (that is tmpfs on top of rootfs) is nice
in some ways, as it makes garbage-collecting the inittmpfs trivial; this
might save some boot time in the more conventional root scenarios.  On
the other hand, it doesn't exactly seem to be a big problem to just
unlink everything.

	-hpa

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
