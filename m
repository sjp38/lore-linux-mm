Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f197.google.com (mail-ig0-f197.google.com [209.85.213.197])
	by kanga.kvack.org (Postfix) with ESMTP id 547FF6B0253
	for <linux-mm@kvack.org>; Thu,  9 Jun 2016 17:02:05 -0400 (EDT)
Received: by mail-ig0-f197.google.com with SMTP id lp2so69497208igb.3
        for <linux-mm@kvack.org>; Thu, 09 Jun 2016 14:02:05 -0700 (PDT)
Received: from mail-oi0-x243.google.com (mail-oi0-x243.google.com. [2607:f8b0:4003:c06::243])
        by mx.google.com with ESMTPS id y64si1848266otb.218.2016.06.09.14.02.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Jun 2016 14:02:04 -0700 (PDT)
Received: by mail-oi0-x243.google.com with SMTP id d132so9774422oig.3
        for <linux-mm@kvack.org>; Thu, 09 Jun 2016 14:02:04 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CABeXuvouhSSAd6nymV4hjq3U2QCO0d-ueeCOnzqrbpdWzjLwjA@mail.gmail.com>
References: <1465448705-25055-1-git-send-email-deepa.kernel@gmail.com>
 <1465448705-25055-5-git-send-email-deepa.kernel@gmail.com>
 <CA+55aFzceGREzGEJda8qt6gv6=iE_yDbM+mO2dJJa0wbu-o-Ww@mail.gmail.com> <CABeXuvouhSSAd6nymV4hjq3U2QCO0d-ueeCOnzqrbpdWzjLwjA@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 9 Jun 2016 14:02:03 -0700
Message-ID: <CA+55aFwcbsCfwDa8VSYQcL4ghq-8stiqUWJ0+xsSvxp1sASi5w@mail.gmail.com>
Subject: Re: [PATCH 04/21] fs: Replace CURRENT_TIME with current_fs_time() for
 inode timestamps
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Deepa Dinamani <deepa.kernel@gmail.com>
Cc: linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>, Thomas Gleixner <tglx@linutronix.de>, Al Viro <viro@zeniv.linux.org.uk>, y2038@lists.linaro.org, Steve French <sfrench@samba.org>, "linux-cifs@vger.kernel.org" <linux-cifs@vger.kernel.org>, samba-technical@lists.samba.org, Joern Engel <joern@logfs.org>, Prasad Joshi <prasadjoshi.linux@gmail.com>, logfs@logfs.org, Andrew Morton <akpm@linux-foundation.org>, Julia Lawall <Julia.Lawall@lip6.fr>, David Howells <dhowells@redhat.com>, Firo Yang <firogm@gmail.com>, Jaegeuk Kim <jaegeuk@kernel.org>, Changman Lee <cm224.lee@samsung.com>, Chao Yu <chao2.yu@samsung.com>, "Linux F2FS DEV, Mailing List" <linux-f2fs-devel@lists.sourceforge.net>, Michal Hocko <mhocko@suse.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "J. Bruce Fields" <bfields@fieldses.org>, Jeff Layton <jlayton@poochiereds.net>, Trond Myklebust <trond.myklebust@primarydata.com>, Anna Schumaker <anna.schumaker@netapp.com>, "David S. Miller" <davem@davemloft.net>, Linux NFS Mailing List <linux-nfs@vger.kernel.org>, Network Development <netdev@vger.kernel.org>, Steven Whitehouse <swhiteho@redhat.com>, Bob Peterson <rpeterso@redhat.com>, cluster-devel <cluster-devel@redhat.com>, Mark Fasheh <mfasheh@suse.com>, Joel Becker <jlbec@evilplan.org>, ocfs2-devel@oss.oracle.com, Anton Vorontsov <anton@enomsg.org>, Colin Cross <ccross@android.com>, Kees Cook <keescook@chromium.org>, Tony Luck <tony.luck@intel.com>, Chris Mason <clm@fb.com>, Josef Bacik <jbacik@fb.com>, David Sterba <dsterba@suse.com>, linux-btrfs <linux-btrfs@vger.kernel.org>, Miklos Szeredi <miklos@szeredi.hu>, "open list:FUSE: FILESYSTEM..." <fuse-devel@lists.sourceforge.net>, Felipe Balbi <balbi@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, USB list <linux-usb@vger.kernel.org>, Doug Ledford <dledford@redhat.com>, Sean Hefty <sean.hefty@intel.com>, Hal Rosenstock <hal.rosenstock@gmail.com>, "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>, Robert Richter <rric@kernel.org>, "oprofile-list@lists.sf.net" <oprofile-list@lists.sf.net>, Alexei Starovoitov <ast@kernel.org>, Hugh Dickins <hughd@google.com>, linux-mm <linux-mm@kvack.org>, Paul Moore <paul@paul-moore.com>, Stephen Smalley <sds@tycho.nsa.gov>, Eric Paris <eparis@parisplace.org>, selinux@tycho.nsa.gov, James Morris <james.l.morris@oracle.com>, "Serge E. Hallyn" <serge@hallyn.com>, LSM List <linux-security-module@vger.kernel.org>, Eric Van Hensbergen <ericvh@gmail.com>, Ron Minnich <rminnich@sandia.gov>, Latchesar Ionkov <lucho@ionkov.net>, V9FS Developers <v9fs-developer@lists.sourceforge.net>, Ian Kent <raven@themaw.net>, autofs mailing list <autofs@vger.kernel.org>, Matthew Garrett <matthew.garrett@nebula.com>, Jeremy Kerr <jk@ozlabs.org>, Matt Fleming <matt@codeblueprint.co.uk>, "linux-efi@vger.kernel.org" <linux-efi@vger.kernel.org>, Peter Hurley <peter@hurleysoftware.com>, Josh Triplett <josh@joshtriplett.org>, Boaz Harrosh <ooo@electrozaur.com>, Benny Halevy <bhalevy@primarydata.com>, open-osd <osd-dev@open-osd.org>, Mike Marshall <hubcap@omnibond.com>, pvfs2-developers@beowulf-underground.org, Nadia Yvette Chambers <nyc@holomorphy.com>, Dave Kleikamp <shaggy@kernel.org>, jfs-discussion@lists.sourceforge.net, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org

On Thu, Jun 9, 2016 at 1:38 PM, Deepa Dinamani <deepa.kernel@gmail.com> wrote:
>
> 1. There are a few link, rename functions which assign times like this:
>
> -       inode->i_ctime = dir->i_ctime = dir->i_mtime = CURRENT_TIME;
> +       inode->i_ctime = dir->i_ctime = dir->i_mtime =
> current_fs_time(dir->i_sb);

So I think you should just pass one any of the two inodes and just add
a comment.

Then, if we hit a filesystem that actually wants to have different
granularity for different inodes, we'll split it up, but even then
we'd be better off than with the superblock, since then we *could*
easily split this one case up into "get directory time" and "get inode
time".


> 2. Also, this means that we will make it an absolute policy that any filesystem
> timestamp that is not directly connected to an inode would have to use
> ktime_get_* apis.

The thing is, those kinds of things are all going to be inside the
filesystem itself.

At that point, the *filesystem* already knows what the timekeeping
rules for that filesystem is.

I think we should strive to design the "current_fs_time()" not for
internal filesystem use, but for actual generic use where we *don't*
know a priori what the rules are, and we have to go to this helper
function to figure it out.

Inside a filesystem, why *shouldn't* the low-level filesystem already
use the normal "get time" functions?

See what I'm saying? The primary value-add to "current_fs_time()" is
for layers like the VFS and security layer that don't know what the
filesystem itself does.

At the low-level filesystem layer, you may just know that "ok, I only
have 32-bit timestamps anyway, so I should just use a 32-bit time
function".

> 3. Even if the filesystem inode has extra timestamps and these are not
> part of vfs inode, we still use
> vfs inode to get the timestamps from current_fs_time(): Eg: ext4 create time

But those already have an inode.

In fact, ext4 is a particularly bad example, since it uses the
ext4_current_time() function to get the time. And that one gets an
inode pointer.

So at least one filesystem that already does this, already uses a
inode-based model.

Everything I see just says "times are about inodes". Anything else
almost has to be filesystem-internal anyway, since the only thing that
is ever visible outside the filesystem (time-wise) is the inode.

And as mentioned, once it's internal to the low-level filesystem, it's
not obvious at all that you'd have to use "currenf_fs_time()" anyway.
The internal filesystem code might very well decide to use other
timekeeping functions.

                 Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
