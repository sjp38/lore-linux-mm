Message-ID: <3D4A5820.6010802@evision.ag>
Date: Fri, 02 Aug 2002 12:00:00 +0200
From: Marcin Dalecki <dalecki@evision.ag>
MIME-Version: 1.0
Subject: Re: large page patch
References: <15690.9727.831144.67179@napali.hpl.hp.com>	<868823061.1028244804@[10.10.2.3]> <15690.10852.935317.603783@napali.hpl.hp.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: davidm@hpl.hp.com
Cc: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>, "David S. Miller" <davem@redhat.com>gh@us.ibm.com, riel@conectiva.com.br, akpm@zip.com.au, linux-kernel@vger.kernel.org, linux-mm@kvack.org, rohit.seth@intel.com, sunil.saxena@intel.com, asit.k.mallick@intel.com
List-ID: <linux-mm.kvack.org>

Uz.ytkownik David Mosberger napisa?:
>>>>>>On Thu, 01 Aug 2002 23:33:26 -0700, "Martin J. Bligh" <Martin.Bligh@us.ibm.com> said:
>>>>>
> 
>   DaveM> In my opinion the proposed large-page patch addresses a
>   DaveM> relatively pressing need for databases (primarily).
>   >>
>   DaveM> Databases want large pages with IPC_SHM, how can this special
>   DaveM> syscal hack address that?
> 
>   >>  I believe the interface is OK in that regard.  AFAIK, Oracle is
>   >> happy with it.
> 
>   Martin> Is Oracle now the world's only database? I think not.
> 
> I didn't say such a thing.  I just don't know what other db vendors/authors
> think of the proposed interface.  I'm sure their feedback would be welcome.

You better don't ask DB people and in esp. the Oracle people
about opinnions on interface design. Unless you wan't something
fscking ugly internally looking like FORTRAN/COBOL coding.
They will always scrap portability/usability use undocumented behaviour 
and so on in the case they can presumably increase theyr pet benchmark
values.
One of the reasons Solaris is *feeling* so slow is that they asked
Oracle people too frequent about oppinions apparently. In esp. they did 
forgett that there are other uses then DB servers ;-).

PS. I just got too much in touch with Oracle to not hate it...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
