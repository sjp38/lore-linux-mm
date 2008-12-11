From: Paul Menage <menage@google.com>
Subject: Re: [RFC][PATCH 1/6] memcg: fix pre_destory handler
Date: Wed, 10 Dec 2008 16:28:38 -0800
Message-ID: <6599ad830812101628o3899c091gd39ef9bd5df851b0@mail.gmail.com>
References: <20081209200213.0e2128c1.kamezawa.hiroyu@jp.fujitsu.com>
	 <20081209200647.a1fa76a9.kamezawa.hiroyu@jp.fujitsu.com>
	 <6599ad830812100240g5e549a5cqe29cbea736788865@mail.gmail.com>
	 <29741.10.75.179.61.1228908581.squirrel@webmail-b.css.fujitsu.com>
	 <6599ad830812101035v33dbc6cfh57aa5510f6d65d54@mail.gmail.com>
	 <20081211092531.175c6830.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755929AbYLKA2w@vger.kernel.org>
In-Reply-To: <20081211092531.175c6830.kamezawa.hiroyu@jp.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

On Wed, Dec 10, 2008 at 4:25 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
>>
>> Can you clarify what you mean by "rolling update of refcnts"?
>>
>  for(..i++)
>        atomic_dec/inc( refcnt[i)
>
> But my first version of this patch did above. I can write it again easily.

I just sent out a small patch collection that had my version of
css_tryget() in it - is that what you had in mind by "rolling update"?

Paul
