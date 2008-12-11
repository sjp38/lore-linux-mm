Return-Path: <linux-kernel-owner+w=401wt.eu-S1755517AbYLKAY5@vger.kernel.org>
MIME-Version: 1.0
In-Reply-To: <20081211092150.b62f8c20.kamezawa.hiroyu@jp.fujitsu.com>
References: <20081209200213.0e2128c1.kamezawa.hiroyu@jp.fujitsu.com>
	 <20081209200647.a1fa76a9.kamezawa.hiroyu@jp.fujitsu.com>
	 <6599ad830812100240g5e549a5cqe29cbea736788865@mail.gmail.com>
	 <29741.10.75.179.61.1228908581.squirrel@webmail-b.css.fujitsu.com>
	 <6599ad830812101035v33dbc6cfh57aa5510f6d65d54@mail.gmail.com>
	 <6599ad830812101100v4dc7f124jded0d767b92e541a@mail.gmail.com>
	 <20081211092150.b62f8c20.kamezawa.hiroyu@jp.fujitsu.com>
Date: Wed, 10 Dec 2008 16:24:44 -0800
Message-ID: <6599ad830812101624i5ba31d04o38d4b39f2d4857d6@mail.gmail.com>
Subject: Re: [RFC][PATCH 1/6] memcg: fix pre_destory handler
From: Paul Menage <menage@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: linux-kernel-owner@vger.kernel.org
List-Archive: <https://lore.kernel.org/lkml/>
List-Post: <mailto:linux-kernel@vger.kernel.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, Dec 10, 2008 at 4:21 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> If per-css, looking up function will be
> ==
> struct cgroup_subsys_state *cgroup_css_lookup(subsys_id, id)
> ==
> Do you mean this ?

Yes, plausibly. And we can presumably have a separate idr per subsystem.

Paul
