Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 6AC436B00DF
	for <linux-mm@kvack.org>; Mon, 12 Dec 2011 06:35:53 -0500 (EST)
Received: by iahk25 with SMTP id k25so11309227iah.14
        for <linux-mm@kvack.org>; Mon, 12 Dec 2011 03:35:52 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAOY=C6HuVEYpkap3dVmgmC7d+SDhvO-zc79RvCvkZCham3MiXg@mail.gmail.com>
References: <CAOY=C6HuVEYpkap3dVmgmC7d+SDhvO-zc79RvCvkZCham3MiXg@mail.gmail.com>
Date: Mon, 12 Dec 2011 12:35:52 +0100
Message-ID: <CAOY=C6GeaqnAOyYgt18xwV3KafHjMA_8QZQBqXEoXox4eNXPwA@mail.gmail.com>
Subject: Re: Oops in d_instantiate (fs/cache.c)
From: Stijn Devriendt <highguy@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Sat, Dec 3, 2011 at 1:19 PM, Stijn Devriendt <highguy@gmail.com> wrote:
> Hi all,
>
> I've had 2 occasions where udev crashed during bootup.
> The second time carried a kernel log where the following line
> "BUG_ON(!list_empty(&entry->d_alias))"
> in d_instantiate is triggered when udev is attempting to
> create a symlink in /dev (which is tmpfs/shmem).
>
> I've tried reproducing this by doing as udev does:
> - create temporary symlink
> - move temporary symlink into place
> in a tight loop (multiple processes) while multiple
> other processes were removing the symlink in a
> tight loop.
> A third script was flushing the dentry/inode cache
> every so often using drop_caches.
> All to no avail.
>
> I've been digging around in the kernel sources,
> but I'm not sure what the d_alias field means
> and what the actual case is the BUG_ON is
> meant to catch. I'd like to be able to find a way
> to reproduce this, because so far it's happened only
> twice in 2 weeks over multiple systems doing
> many reboots in a testing setup.
> Can someone explain this to me in short?
>
> Thanks,
> Stijn

Trying resend...

Stijn

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
