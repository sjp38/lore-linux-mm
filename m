Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 6A48E6B004A
	for <linux-mm@kvack.org>; Sat, 14 Apr 2012 07:53:57 -0400 (EDT)
Message-ID: <1334404423.2528.75.camel@twins>
Subject: Re: [Lsf] [RFC] writeback and cgroup
From: Peter Zijlstra <peterz@infradead.org>
Date: Sat, 14 Apr 2012 13:53:43 +0200
In-Reply-To: <20120404184909.GB29686@dhcp-172-17-108-109.mtv.corp.google.com>
References: <20120403183655.GA23106@dhcp-172-17-108-109.mtv.corp.google.com>
	 <20120404145134.GC12676@redhat.com>
	 <20120404184909.GB29686@dhcp-172-17-108-109.mtv.corp.google.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Vivek Goyal <vgoyal@redhat.com>, ctalbott@google.com, rni@google.com, andrea@betterlinux.com, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, lsf@lists.linux-foundation.org, linux-mm@kvack.org, jmoyer@redhat.com, lizefan@huawei.com, linux-fsdevel@vger.kernel.org, cgroups@vger.kernel.org

On Wed, 2012-04-04 at 11:49 -0700, Tejun Heo wrote:
> > - How to handle NFS.
>=20
> As said above, maybe through network based bdi pressure propagation,
> Maybe some other special case mechanism.  Unsure but I don't think
> this concern should dictate the whole design.=20

NFS has a custom bdi implementation and implements congestion control
based on the number of outstanding writeback pages.

See fs/nfs/write.c:nfs_{set,end}_page_writeback

All !block based filesystems have their own BDI implementation, I'm not
sure on the congestion implementation of anything other than NFS though.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
