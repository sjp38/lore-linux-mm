Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 8CAE16B0032
	for <linux-mm@kvack.org>; Tue,  9 Jul 2013 13:13:00 -0400 (EDT)
Received: by mail-la0-f48.google.com with SMTP id lx15so4878991lab.21
        for <linux-mm@kvack.org>; Tue, 09 Jul 2013 10:12:58 -0700 (PDT)
Message-ID: <51DC4497.6060107@openvz.org>
Date: Tue, 09 Jul 2013 21:12:55 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
Subject: Re: [PATCH RFC] fsio: filesystem io accounting cgroup
References: <20130708100046.14417.12932.stgit@zurg> <20130709153907.GA17972@thunk.org>
In-Reply-To: <20130709153907.GA17972@thunk.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Sha Zhengju <handai.szj@gmail.com>, devel@openvz.org

Theodore Ts'o wrote:
> Another major problem with this concept is that it lumps all I/O's
> into a single cgroup.  So I/O's from pseudo filesystems (such as
> reading from /sys/kernel/debug/tracing/trace_pipe), networked file
> systems such as NFS, and I/O to various different block devices all
> get counted in a single per-cgroup limit.
>
> This doesn't seem terribly useful to me.  Network resources and block
> resources are quite different, and counting pseudo file systems and
> ram disks makes no sense at all.

Yep, I know it. I've already mentioned about this as first planned improvement:

|* Split bdi into several tiers and account them separately. For example:
|  hdd/ssd/usb/nfs. In complicated containerized environments that might be
|  different kinds of storages with different limits and billing. This is more
|  usefull that independent per-disk accounting and much easier to implement
|  because all per-tier structures are allocated before disk appearance.

Accounting each BDI separately doesn't very useful too, so I've chosen
something in the middle.

>
> Regards,
>
> 					- Ted
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email:<a href=mailto:"dont@kvack.org">  email@kvack.org</a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
