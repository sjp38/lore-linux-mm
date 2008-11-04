Received: from zps19.corp.google.com (zps19.corp.google.com [172.25.146.19])
	by smtp-out.google.com with ESMTP id mA46NDqL022844
	for <linux-mm@kvack.org>; Mon, 3 Nov 2008 22:23:13 -0800
Received: from rv-out-0506.google.com (rvbk40.prod.google.com [10.140.87.40])
	by zps19.corp.google.com with ESMTP id mA46NBiQ004360
	for <linux-mm@kvack.org>; Mon, 3 Nov 2008 22:23:12 -0800
Received: by rv-out-0506.google.com with SMTP id k40so3145555rvb.13
        for <linux-mm@kvack.org>; Mon, 03 Nov 2008 22:23:11 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20081104151748.4731f5a1.kamezawa.hiroyu@jp.fujitsu.com>
References: <20081031115057.6da3dafd.kamezawa.hiroyu@jp.fujitsu.com>
	 <20081031115241.1399d605.kamezawa.hiroyu@jp.fujitsu.com>
	 <6599ad830811032215j3ce5dcc1g6d0c3e9439a004d@mail.gmail.com>
	 <20081104151748.4731f5a1.kamezawa.hiroyu@jp.fujitsu.com>
Date: Mon, 3 Nov 2008 22:23:11 -0800
Message-ID: <6599ad830811032223r4c655c2dsc0c4b61c048039f9@mail.gmail.com>
Subject: Re: [RFC][PATCH 1/5] memcg : force_empty to do move account
From: Paul Menage <menage@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, hugh@veritas.com, taka@valinux.co.jp
List-ID: <linux-mm.kvack.org>

On Mon, Nov 3, 2008 at 10:17 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
>> >
>> >        mem = memcg;
>> > -       ret = mem_cgroup_try_charge(mm, gfp_mask, &mem);
>> > +       ret = __mem_cgroup_try_charge(mm, gfp_mask, &mem, true);
>>
>> Isn't this the same as the definition of mem_cgroup_try_charge()? So
>> you could leave it as-is?
>>
> try_charge is called by other places....swapin.
>

No, I mean here you can call mem_cgroup_try_charge(...) rather than
__mem_cgroup_try_charge(..., true).

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
