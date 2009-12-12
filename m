Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 85FB16B003D
	for <linux-mm@kvack.org>; Sat, 12 Dec 2009 08:13:54 -0500 (EST)
Received: by fxm9 with SMTP id 9so1790713fxm.10
        for <linux-mm@kvack.org>; Sat, 12 Dec 2009 05:13:52 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <cc557aab0912120511r7c83e97di3f97d2bb5eae326c@mail.gmail.com>
References: <cover.1260571675.git.kirill@shutemov.name>
	 <ca59c422b495907678915db636f70a8d029cbf3a.1260571675.git.kirill@shutemov.name>
	 <c1847dfb5c4fed1374b7add236d38e0db02eeef3.1260571675.git.kirill@shutemov.name>
	 <747ea0ec22b9348208c80f86f7a813728bf8e50a.1260571675.git.kirill@shutemov.name>
	 <9e6e8d687224c6cbc54281f7c3d07983f701f93d.1260571675.git.kirill@shutemov.name>
	 <20091212121902.e95f9561.d-nishimura@mtf.biglobe.ne.jp>
	 <cc557aab0912120511r7c83e97di3f97d2bb5eae326c@mail.gmail.com>
Date: Sat, 12 Dec 2009 15:13:52 +0200
Message-ID: <cc557aab0912120513q6e9cd518y1af2c6fbbd407b85@mail.gmail.com>
Subject: Re: [PATCH RFC v2 4/4] memcg: implement memory thresholds
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: nishimura@mxp.nes.nec.co.jp
Cc: containers@lists.linux-foundation.org, linux-mm@kvack.org, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, Dan Malek <dan@embeddedalley.com>, Vladislav Buzov <vbuzov@embeddedalley.com>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sat, Dec 12, 2009 at 3:11 PM, Kirill A. Shutemov
<kirill@shutemov.name> wrote:
> Ok, I'll move it. It will affect performance of
> mem_cgroup_invalidate_thresholds(),
> but I don't think that it's important.

s/mem_cgroup_invalidate_thresholds()/mem_cgroup_register_event() and
mem_cgroup_unregister_event()/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
