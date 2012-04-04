Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 801EB6B007E
	for <linux-mm@kvack.org>; Wed,  4 Apr 2012 11:36:05 -0400 (EDT)
Received: by qadb15 with SMTP id b15so549231qad.9
        for <linux-mm@kvack.org>; Wed, 04 Apr 2012 08:36:04 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120404145134.GC12676@redhat.com>
References: <20120403183655.GA23106@dhcp-172-17-108-109.mtv.corp.google.com>
	<20120404145134.GC12676@redhat.com>
Date: Wed, 4 Apr 2012 10:36:04 -0500
Message-ID: <CAH2r5mtwQa0Uu=_Yd2JywVJXA=OMGV43X_OUfziC-yeVy9BGtQ@mail.gmail.com>
Subject: Re: [Lsf] [RFC] writeback and cgroup
From: Steve French <smfrench@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vivek Goyal <vgoyal@redhat.com>
Cc: Tejun Heo <tj@kernel.org>, ctalbott@google.com, rni@google.com, andrea@betterlinux.com, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, lsf@lists.linux-foundation.org, linux-mm@kvack.org, jmoyer@redhat.com, lizefan@huawei.com, linux-fsdevel@vger.kernel.org, cgroups@vger.kernel.org

On Wed, Apr 4, 2012 at 9:51 AM, Vivek Goyal <vgoyal@redhat.com> wrote:
> On Tue, Apr 03, 2012 at 11:36:55AM -0700, Tejun Heo wrote:
>
> Hi Tejun,
>
> Thanks for the RFC and looking into this issue. Few thoughts inline.
>
> [..]
>> IIUC, without cgroup, the current writeback code works more or less
>> like this. =A0Throwing in cgroup doesn't really change the fundamental
>> design. =A0Instead of a single pipe going down, we just have multiple
>> pipes to the same device, each of which should be treated separately.
>> Of course, a spinning disk can't be divided that easily and their
>> performance characteristics will be inter-dependent, but the place to
>> solve that problem is where the problem is, the block layer.
>
> How do you take care of thorottling IO to NFS case in this model? Current
> throttling logic is tied to block device and in case of NFS, there is no
> block device.

Similarly smb2 gets congestion info (number of "credits") returned from
the server on every response - but not sure why congestion
control is tied to the block device when this would create
problems for network file systems

--=20
Thanks,

Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
