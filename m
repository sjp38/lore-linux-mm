Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 10D348D0039
	for <linux-mm@kvack.org>; Tue,  8 Feb 2011 11:46:19 -0500 (EST)
MIME-Version: 1.0
Message-ID: <e908a602-35b8-4ecc-aad2-8973da171161@default>
Date: Tue, 8 Feb 2011 08:30:57 -0800 (PST)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH V1 3/3] drivers/staging: kztmem: misc build/config
References: <20110118172151.GA20507@ca-server1.us.oracle.com
 20110204212843.GA18924@kroah.com>
In-Reply-To: <20110204212843.GA18924@kroah.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg KH <greg@kroah.com>
Cc: gregkh@suse.de, Chris Mason <chris.mason@oracle.com>, akpm@linux-foundation.org, torvalds@linux-foundation.org, matthew@wil.cx, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ngupta@vflare.org, jeremy@goop.org, Kurt Hackel <kurt.hackel@oracle.com>, npiggin@kernel.dk, riel@redhat.com, Konrad Wilk <konrad.wilk@oracle.com>, mel@csn.ul.ie, minchan.kim@gmail.com, kosaki.motohiro@jp.fujitsu.com, sfr@canb.auug.org.au, wfg@mail.ustc.edu.cn, tytso@mit.edu, viro@ZenIV.linux.org.uk, hughd@google.com, hannes@cmpxchg.org

> From: Greg KH [mailto:greg@kroah.com]
> Subject: Re: [PATCH V1 3/3] drivers/staging: kztmem: misc build/config
>=20
> On Tue, Jan 18, 2011 at 09:21:51AM -0800, Dan Magenheimer wrote:
> > [PATCH V1 3/3] drivers/staging: kztmem: misc build/config
> >
> > Makefiles and Kconfigs to build kztmem in drivers/staging
> >
> > There is a dependency on xvmalloc.* which in 2.6.37 resides
> > in drivers/staging/zram.  Should this move or disappear,
> > some Makefile/Kconfig changes will be required.
>=20
> There is some other kind of dependancy as well, because I get the
> following errors when building:
> :=20
> If you require a kbuild dependancy, then put it in your Kconfig file
> please, don't break the build.
>=20
> I'll not apply these patches for now until that's fixed up.
>=20
> thanks,
> greg k-h

Hi Greg --

Just wanted to confirm that this is now fixed and hope that you
can now apply BUT note that per agreement with Nitin Gupta [1]
the patchset has been modified to be named zcache and the
renamed patchset (with the proper kbuild dependency) has been
posted at [2].

ALSO, could you please confirm the path by which this patchset
will find its way upstream?  I see from your blog [3] that after
you apply it, I should be able to see it in sfr's linux-next
tree [4] which IIUC sfr pulls regularly from your staging-next
tree [5].  And I think at the next merge window, YOU will
provide the pull request to Linus included with any other
staging drivers?  Is this all correct?

Sorry for the driver-staging-newbie question but your blog
entry is 2 years old and I'd like to (1) ensure that I don't
drop some important task *I* still need to do and (2) be able
to track the progress of zcache through the various trees as
a self-educational exercise.

Thanks,
Dan

[1] https://lkml.org/lkml/2011/2/5/181=20
[2] https://lkml.org/lkml/2011/2/6/346
    https://lkml.org/lkml/2011/2/6/345=20
    https://lkml.org/lkml/2011/2/6/344=20
    https://lkml.org/lkml/2011/2/6/343=20
[3] http://www.kroah.com/log/linux/linux-staging-update.html=20
[4] http://git.kernel.org/?p=3Dlinux/kernel/git/sfr/linux-next.git=20
[5] http://git.kernel.org/?p=3Dlinux/kernel/git/gregkh/staging-2.6.git;a=3D=
shortlog;h=3Drefs/heads/staging-next

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
