From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: [PATCH 00/14] Present useful limits to user (v2)
Date: Fri, 15 Jul 2016 13:54:44 -0700
Message-ID: <201607152054.u6FKslD1005327__10643.7137387276$1468631361$gmane$org@mail.zytor.com>
References: <1468578983-28229-1-git-send-email-toiwoton@gmail.com> <20160715124330.GR30154@twins.programming.kicks-ass.net> <28b4b919-4f50-d9f6-c5e1-d1e92ea1ba1c@gmail.com> <20160715135956.GA3115@twins.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by plane.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1bOE6H-0004Fx-KH
	for glkm-linux-mm-2@m.gmane.org; Sat, 16 Jul 2016 03:09:01 +0200
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 52F0E6B0266
	for <linux-mm@kvack.org>; Fri, 15 Jul 2016 16:58:11 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id c52so224953367qte.2
        for <linux-mm@kvack.org>; Fri, 15 Jul 2016 13:58:11 -0700 (PDT)
Received: from mail.zytor.com (torg.zytor.com. [2001:1868:205::12])
        by mx.google.com with ESMTPS id f84si3039299ywc.105.2016.07.15.13.58.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Jul 2016 13:58:07 -0700 (PDT)
In-Reply-To: <20160715135956.GA3115@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Topi Miettinen <toiwoton@gmail.com>
Cc: linux-kernel@vger.kernel.org, Jonathan Corbet <corbet@lwn.net>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Alexander Graf <agraf@suse.com>, Paolo Bonzini <pbonzini@redhat.com>, Radim Kr??m???? <rkrcmar@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "maintainer:X86 ARCHITECTURE (32-BIT AND 64-BIT)" <x86@kernel.org>, Doug Ledford <dledford@redhat.com>, Sean Hefty <sean.hefty@intel.com>, Hal Rosenstock <hal.rosenstock@gmail.com>, Mike Marciniszyn <mike.marciniszyn@intel.com>, Dennis Dalessandro <dennis.dalessandro@intel.com>, Christian Benvenuti <benve@cisco.com>, Dave Goodell <dgoodell@cisco.c>

<lizefan@huawei.com>,Johannes Weiner <hannes@cmpxchg.org>,Alexei Starovoi=
tov <ast@kernel.org>,Arnaldo Carvalho de Melo <acme@kernel.org>,Alexander=
 Shishkin <alexander.shishkin@linux.intel.com>,Balbir Singh <bsingharora@=
gmail.com>,Markus Elfring <elfring@users.sourceforge.net>,"David S. Mille=
r" <davem@davemloft.net>,Nicolas Dichtel <nicolas.dichtel@6wind.com>,Andr=
ew Morton <akpm@linux-foundation.org>,Konstantin Khlebnikov <koct9i@gmail=
.com>,Jiri Slaby <jslaby@suse.cz>,Cyrill Gorcunov <gorcunov@openvz.org>,M=
ichal Hocko <mhocko@suse.com>,Vlastimil Babka <vbabka@suse.cz>,Dave Hanse=
n <dave.hansen@linux.intel.com>,Greg Kroah-Hartman <gregkh@linuxfoundatio=
n.org>,Dan Carpenter <dan.carpenter@oracle.com>,Michael Kerrisk <mtk.manp=
ages@gmail.com>,"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,Ma=
rcus Gelderie <redmnic@gmail.com>,Vladimir Davydov <vdavydov@virtuozzo.co=
m>,Joe Perches <joe@perches.com>,Frederic Weisbecker <fweisbec@gmail.com>=
,Andrea Arcangeli <aarcange@redhat.com>,!
 "Eric W.
Biederman" <ebiederm@xmission.com>,Andi Kleen <ak@linux.intel.com>,Oleg N=
esterov <oleg@redhat.com>,Stas Sergeev <stsp@list.ru>,Amanieu d'Antras <a=
manieu@gmail.com>,Richard Weinberger <richard@nod.at>,Wang Xiaoqiang <wan=
gxq10@lzu.edu.cn>,Helge Deller <deller@gmx.de>,Mateusz Guzik <mguzik@redh=
at.com>,Alex Thorlton <athorlton@sgi.com>,Ben Segall <bsegall@google.com>=
,John Stultz <john.stultz@linaro.org>,Rik van Riel <riel@redhat.com>,Eric=
 B Munson <emunson@akamai.com>,Alexey Klimov <klimov.linux@gmail.com>,Che=
n Gang <gang.chen.5i5j@gmail.com>,Andrey Ryabinin <aryabinin@virtuozzo.co=
m>,David Rientjes <rientjes@google.com>,Hugh Dickins <hughd@google.com>,A=
lexander Kuleshov <kuleshovmail@gmail.com>,"open list:DOCUMENTATION" <lin=
ux-doc@vger.kernel.org>,"open list:IA64 (Itanium) PLATFORM" <linux-ia64@v=
ger.kernel.org>,"open list:KERNEL VIRTUAL MACHINE (KVM) FOR POWERPC" <kvm=
-ppc@vger.kernel.org>,"open list:KERNEL VIRTUAL MACHINE (KVM)" <kvm@vger.=
kernel.org>,"open list:LINUX FOR POWERPC!
  (32-BIT
AND 64-BIT)" <linuxppc-dev@lists.ozlabs.org>,"open list:INFINIBAND SUBSYS=
TEM" <linux-rdma@vger.kernel.org>,"open list:FILESYSTEMS (VFS and infrast=
ructure)" <linux-fsdevel@vger.kernel.org>,"open list:CONTROL GROUP (CGROU=
P)" <cgroups@vger.kernel.org>,"open list:BPF (Safe dynamic programs and t=
ools)" <netdev@vger.kernel.org>,"open list:MEMORY MANAGEMENT" <linux-mm@k=
vack.org>
Message-ID: <D79806FE-E6B9-481B-8AA2-A1800419D9B5@zytor.com>

On July 15, 2016 6:59:56 AM PDT, Peter Zijlstra <peterz@infradead.org> wr=
ote:
>On Fri, Jul 15, 2016 at 01:52:48PM +0000, Topi Miettinen wrote:
>> On 07/15/16 12:43, Peter Zijlstra wrote:
>> > On Fri, Jul 15, 2016 at 01:35:47PM +0300, Topi Miettinen wrote:
>> >> Hello,
>> >>
>> >> There are many basic ways to control processes, including
>capabilities,
>> >> cgroups and resource limits. However, there are far fewer ways to
>find out
>> >> useful values for the limits, except blind trial and error.
>> >>
>> >> This patch series attempts to fix that by giving at least a nice
>starting
>> >> point from the highwater mark values of the resources in question.
>> >> I looked where each limit is checked and added a call to update
>the mark
>> >> nearby.
>> >=20
>> > And how is that useful? Setting things to the high watermark is
>> > basically the same as not setting the limit at all.
>>=20
>> What else would you use, too small limits?
>
>That question doesn't make sense.
>
>What's the point of setting a limit if it ends up being the same as
>no-limit (aka unlimited).
>
>If you cannot explain; and you have not so far; what use these values
>are, why would we look at the patches.

One reason is to catch a malfunctioning process rather than dragging the =
whole system down with it.  It could also be useful for development.
--=20
Sent from my Android device with K-9 Mail. Please excuse brevity and form=
atting.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
