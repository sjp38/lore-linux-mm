Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 1F4AD6B0071
	for <linux-mm@kvack.org>; Fri, 30 Nov 2012 10:01:21 -0500 (EST)
Date: Fri, 30 Nov 2012 15:01:05 +0000
From: "Richard W.M. Jones" <rjones@redhat.com>
Subject: Re: O_DIRECT on tmpfs (again)
Message-ID: <20121130150105.GA4883@rhmail.home.annexia.org>
References: <x49ip8rf2yw.fsf@segfault.boston.devel.redhat.com>
 <alpine.LNX.2.00.1211281248270.14968@eggly.anvils>
 <50B6830A.20308@oracle.com>
 <x498v9kwhzy.fsf@segfault.boston.devel.redhat.com>
 <alpine.LNX.2.00.1211291659260.3510@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.00.1211291659260.3510@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Jeff Moyer <jmoyer@redhat.com>, Dave Kleikamp <dave.kleikamp@oracle.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Thu, Nov 29, 2012 at 05:32:14PM -0800, Hugh Dickins wrote:
> Like you, I'm really hoping someone will join in and say they'd been
> disadvantaged by lack of O_DIRECT on tmpfs: no strong feeling myself.

Not disadvantaged as such, but we have had a workaround in libguestfs
for a very long time.

If you use certain qemu caching modes, then qemu will open the backing
disk file using O_DIRECT.  This breaks if the backing file happens to
be on a tmpfs, which for libguestfs would not be unusual -- we often
make or use temporary disk images for various reasons, and people
sometimes have /tmp on a tmpfs.

In 2009 I added code to libguestfs so that if the underlying
filesystem doesn't support O_DIRECT, then we avoid the troublesome
qemu caching modes.  The code is here:

  https://github.com/libguestfs/libguestfs/blob/master/src/launch.c#L147

Since the workaround exists and has been in use for years, we don't
need tmpfs to change.

Rich.

-- 
Richard Jones, Virtualization Group, Red Hat http://people.redhat.com/~rjones
libguestfs lets you edit virtual machines.  Supports shell scripting,
bindings from many languages.  http://libguestfs.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
