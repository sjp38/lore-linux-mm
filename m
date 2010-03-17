Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 36F2C6B013C
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 13:48:47 -0400 (EDT)
Received: from hpaq5.eem.corp.google.com (hpaq5.eem.corp.google.com [10.3.21.5])
	by smtp-out.google.com with ESMTP id o2HHmemq020217
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 10:48:40 -0700
Received: from yxe4 (yxe4.prod.google.com [10.190.2.4])
	by hpaq5.eem.corp.google.com with ESMTP id o2HHmchf027237
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 18:48:39 +0100
Received: by yxe4 with SMTP id 4so193111yxe.28
        for <linux-mm@kvack.org>; Wed, 17 Mar 2010 10:48:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100316164121.024e35d8.nishimura@mxp.nes.nec.co.jp>
References: <1268609202-15581-1-git-send-email-arighi@develer.com>
	<1268609202-15581-3-git-send-email-arighi@develer.com> <20100316164121.024e35d8.nishimura@mxp.nes.nec.co.jp>
From: Greg Thelen <gthelen@google.com>
Date: Wed, 17 Mar 2010 09:48:18 -0800
Message-ID: <49b004811003171048h5f27405oe6ea39a103bc4ee3@mail.gmail.com>
Subject: Re: [PATCH -mmotm 2/5] memcg: dirty memory documentation
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Andrea Righi <arighi@develer.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Vivek Goyal <vgoyal@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Trond Myklebust <trond.myklebust@fys.uio.no>, Suleiman Souhlal <suleiman@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 15, 2010 at 11:41 PM, Daisuke Nishimura
<nishimura@mxp.nes.nec.co.jp> wrote:
> On Mon, 15 Mar 2010 00:26:39 +0100, Andrea Righi <arighi@develer.com> wro=
te:
>> Document cgroup dirty memory interfaces and statistics.
>>
>> Signed-off-by: Andrea Righi <arighi@develer.com>
>> ---
>> =A0Documentation/cgroups/memory.txt | =A0 36 +++++++++++++++++++++++++++=
+++++++++
>> =A01 files changed, 36 insertions(+), 0 deletions(-)
>>
>> diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/me=
mory.txt
>> index 49f86f3..38ca499 100644
>> --- a/Documentation/cgroups/memory.txt
>> +++ b/Documentation/cgroups/memory.txt
>> @@ -310,6 +310,11 @@ cache =A0 =A0 =A0 =A0 =A0 =A0- # of bytes of page c=
ache memory.
>> =A0rss =A0 =A0 =A0 =A0 =A0- # of bytes of anonymous and swap cache memor=
y.
>> =A0pgpgin =A0 =A0 =A0 =A0 =A0 =A0 =A0 - # of pages paged in (equivalent =
to # of charging events).
>> =A0pgpgout =A0 =A0 =A0 =A0 =A0 =A0 =A0- # of pages paged out (equivalent=
 to # of uncharging events).
>> +filedirty =A0 =A0- # of pages that are waiting to get written back to t=
he disk.
>> +writeback =A0 =A0- # of pages that are actively being written back to t=
he disk.
>> +writeback_tmp =A0 =A0 =A0 =A0- # of pages used by FUSE for temporary wr=
iteback buffers.
>> +nfs =A0 =A0 =A0 =A0 =A0- # of NFS pages sent to the server, but not yet=
 committed to
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 the actual storage.

Should these new memory.stat counters (filedirty, etc) report byte
counts rather than page counts?  I am thinking that byte counters
would make reporting more obvious depending on how heterogeneous page
sizes are used. Byte counters would also agree with /proc/meminfo.
Within the kernel we could still maintain page counts.  The only
change would be to the reporting routine, mem_cgroup_get_local_stat(),
which would scale the page counts by PAGE_SIZE as it does for for
cache,rss,etc.

--
Greg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
