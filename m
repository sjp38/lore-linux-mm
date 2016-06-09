Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id D2FAD6B0253
	for <linux-mm@kvack.org>; Thu,  9 Jun 2016 16:38:23 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id h144so96841552ita.1
        for <linux-mm@kvack.org>; Thu, 09 Jun 2016 13:38:23 -0700 (PDT)
Received: from mail-it0-x242.google.com (mail-it0-x242.google.com. [2607:f8b0:4001:c0b::242])
        by mx.google.com with ESMTPS id o135si8912359ith.75.2016.06.09.13.38.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Jun 2016 13:38:22 -0700 (PDT)
Received: by mail-it0-x242.google.com with SMTP id r205so6615997itd.1
        for <linux-mm@kvack.org>; Thu, 09 Jun 2016 13:38:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CA+55aFzceGREzGEJda8qt6gv6=iE_yDbM+mO2dJJa0wbu-o-Ww@mail.gmail.com>
References: <1465448705-25055-1-git-send-email-deepa.kernel@gmail.com>
 <1465448705-25055-5-git-send-email-deepa.kernel@gmail.com> <CA+55aFzceGREzGEJda8qt6gv6=iE_yDbM+mO2dJJa0wbu-o-Ww@mail.gmail.com>
From: Deepa Dinamani <deepa.kernel@gmail.com>
Date: Thu, 9 Jun 2016 13:38:21 -0700
Message-ID: <CABeXuvouhSSAd6nymV4hjq3U2QCO0d-ueeCOnzqrbpdWzjLwjA@mail.gmail.com>
Subject: Re: [PATCH 04/21] fs: Replace CURRENT_TIME with current_fs_time() for
 inode timestamps
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>, Thomas Gleixner <tglx@linutronix.de>, Al Viro <viro@zeniv.linux.org.uk>, y2038@lists.linaro.org, Steve French <sfrench@samba.org>, "linux-cifs@vger.kernel.org" <linux-cifs@vger.kernel.org>, samba-technical@lists.samba.org, Joern Engel <joern@logfs.org>, Prasad Joshi <prasadjoshi.linux@gmail.com>, logfs@logfs.org, Andrew Morton <akpm@linux-foundation.org>, Julia Lawall <Julia.Lawall@lip6.fr>, David Howells <dhowells@redhat.com>, Firo Yang <firogm@gmail.com>, Jaegeuk Kim <jaegeuk@kernel.org>, Changman Lee <cm224.lee@samsung.com>, Chao Yu <chao2.yu@samsung.com>, "Linux F2FS DEV, Mailing List" <linux-f2fs-devel@lists.sourceforge.net>, Michal Hocko <mhocko@suse.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "J. Bruce Fields" <bfields@fieldses.org>, Jeff Layton <jlayton@poochiereds.net>, Trond Myklebust <trond.myklebust@primarydata.com>, Anna Schumaker <anna.schumaker@netapp.com>, "David S. Miller" <davem@davemloft.net>, Linux NFS Mailing List <linux-nfs@vger.kernel.org>, Network Development <netdev@vger.kernel.org>, Steven Whitehouse <swhiteho@redhat.com>, Bob Peterson <rpeterso@redhat.com>, cluster-devel <cluster-devel@redhat.com>, Mark Fasheh <mfasheh@suse.com>, Joel Becker <jlbec@evilplan.org>, ocfs2-devel@oss.oracle.com, Anton Vorontsov <anton@enomsg.org>, Colin Cross <ccross@android.com>, Kees Cook <keescook@chromium.org>, Tony Luck <tony.luck@intel.com>, Chris Mason <clm@fb.com>, Josef Bacik <jbacik@fb.com>, David Sterba <dsterba@suse.com>, linux-btrfs <linux-btrfs@vger.kernel.org>, Miklos Szeredi <miklos@szeredi.hu>, "open list:FUSE: FILESYSTEM..." <fuse-devel@lists.sourceforge.net>, Felipe Balbi <balbi@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, USB list <linux-usb@vger.kernel.org>, Doug Ledford <dledford@redhat.com>, Sean Hefty <sean.hefty@intel.com>, Hal Rosenstock <hal.rosenstock@gmail.com>, "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>, Robert Richter <rric@kernel.org>, "oprofile-list@lists.sf.net" <oprofile-list@lists.sf.net>, Alexei Starovoitov <ast@kernel.org>, Hugh Dickins <hughd@google.com>, linux-mm <linux-mm@kvack.org>, Paul Moore <paul@paul-moore.com>, Stephen Smalley <sds@tycho.nsa.gov>, Eric Paris <eparis@parisplace.org>, selinux@tycho.nsa.gov, James Morris <james.l.morris@oracle.com>, "Serge E. Hallyn" <serge@hallyn.com>, LSM List <linux-security-module@vger.kernel.org>, Eric Van Hensbergen <ericvh@gmail.com>, Ron Minnich <rminnich@sandia.gov>, Latchesar Ionkov <lucho@ionkov.net>, V9FS Developers <v9fs-developer@lists.sourceforge.net>, Ian Kent <raven@themaw.net>, autofs mailing list <autofs@vger.kernel.org>, Matthew Garrett <matthew.garrett@nebula.com>, Jeremy Kerr <jk@ozlabs.org>, Matt Fleming <matt@codeblueprint.co.uk>, "linux-efi@vger.kernel.org" <linux-efi@vger.kernel.org>, Peter Hurley <peter@hurleysoftware.com>, Josh Triplett <josh@joshtriplett.org>, Boaz Harrosh <ooo@electrozaur.com>, Benny Halevy <bhalevy@primarydata.com>, open-osd <osd-dev@open-osd.org>, Mike Marshall <hubcap@omnibond.com>, pvfs2-developers@beowulf-underground.org, Nadia Yvette Chambers <nyc@holomorphy.com>, Dave Kleikamp <shaggy@kernel.org>, jfs-discussion@lists.sourceforge.net, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org

On Thu, Jun 9, 2016 at 12:08 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
> On Wed, Jun 8, 2016 at 10:04 PM, Deepa Dinamani <deepa.kernel@gmail.com> wrote:
>> CURRENT_TIME macro is not appropriate for filesystems as it
>> doesn't use the right granularity for filesystem timestamps.
>> Use current_fs_time() instead.
>
> Again - using the inode instead fo the syuperblock in tghis patch
> would have made the patch much more obvious (it could have been 99%
> generated with the sed-script I sent out a week or two ago), and it
> would have made it unnecessary to add these kinds of things:
>
>> diff --git a/drivers/usb/core/devio.c b/drivers/usb/core/devio.c
>> index e9f5043..85c12f0 100644
>> --- a/drivers/usb/core/devio.c
>> +++ b/drivers/usb/core/devio.c
>> @@ -2359,6 +2359,7 @@ static long usbdev_do_ioctl(struct file *file, unsigned int cmd,
>>  {
>>         struct usb_dev_state *ps = file->private_data;
>>         struct inode *inode = file_inode(file);
>> +       struct super_block *sb = inode->i_sb;
>>         struct usb_device *dev = ps->dev;
>>         int ret = -ENOTTY;
>
> where we add a new variable just because the calling convention was wrong.
>
> It's not even 100% obvious that a filesystem has to have one single
> time representation, so making the time function about the entity
> whose time is set is also conceptually a much better model, never mind
> that it is just what every single user seems to want anyway.
>
> So I'd *much* rather see
>
> +       inode->i_atime = inode->i_mtime = inode->i_ctime =
> current_fs_time(inode);
>
> over seeing either of these two variants::
>
> +       inode->i_atime = inode->i_mtime = inode->i_ctime =
> current_fs_time(inode->i_sb);
> +       ret->i_atime = ret->i_mtime = ret->i_ctime = current_fs_time(sb);
>
> because the first of those variants (grep for current_fs_time() in the
> current git tree, and notice that it's the common one) we have the
> pointless "let's chase a pointer in every caller"
>
> And while it's true that the second variant is natural for *some*
> situations, I've yet to find one where it wasn't equally sane to just
> pass in the inode instead.

I did try changing the patches to pass inode.
But, there are a few instances that made me think that keeping
super_block was beneficial.

1. There are a few link, rename functions which assign times like this:

-       inode->i_ctime = dir->i_ctime = dir->i_mtime = CURRENT_TIME;
+       inode->i_ctime = dir->i_ctime = dir->i_mtime =
current_fs_time(dir->i_sb);

Now, if we pass in inode, we end up making 2 calls to current_fs_time().
We could actually just use 1 call because for all parameters the
function uses, they are identical.
But, it seems odd to assume that the function wouldn't use the inode,
even though it is getting passed in to the function.

2. Also, this means that we will make it an absolute policy that any filesystem
timestamp that is not directly connected to an inode would have to use
ktime_get_* apis.
Some timestamps use the same on disk format and might be useful to
have same api to be reused.
Eg: [patch 6/21] of the current series

3. Even if the filesystem inode has extra timestamps and these are not
part of vfs inode, we still use
vfs inode to get the timestamps from current_fs_time(): Eg: ext4 create time

4. And, filesystem attributes must be assigned only after the inode is
created or use ktime apis.
And, only when these get assigned to inode, they will call timespec_trunc().

5. 2 and 3 might lead to more code rearrangement for few filesystems.
These will lead to more patches probably and they will not be mechanical.

If these are not a problem, I can update the series that accepts inode as an
argument instead of super_block.

-Deepa

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
