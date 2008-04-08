From: "Paul Menage" <menage@google.com>
Subject: Re: [-mm] Add an owner to the mm_struct (v8)
Date: Tue, 8 Apr 2008 00:29:45 -0700
Message-ID: <6599ad830804080029v1d8f2ff7g5254f32362fd7cb9@mail.gmail.com>
References: <20080404080544.26313.38199.sendpatchset@localhost.localdomain>
	 <47F7BB69.3000502@linux.vnet.ibm.com>
	 <6599ad830804051057n2f2802e4w6179f2e108467494@mail.gmail.com>
	 <47F7CC08.4090209@linux.vnet.ibm.com>
	 <6599ad830804051629k3649dbc4na92bb3d0cd7a0492@mail.gmail.com>
	 <47F861C8.7080700@linux.vnet.ibm.com>
	 <6599ad830804072337g2e7b4613hdcc05062dc2ca4e0@mail.gmail.com>
	 <47FB162D.1020506@linux.vnet.ibm.com>
	 <6599ad830804072357o2fd5e9bco3309d151e270e62e@mail.gmail.com>
	 <47FB193A.8070801@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752512AbYDHHaL@vger.kernel.org>
In-Reply-To: <47FB193A.8070801@linux.vnet.ibm.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: balbir@linux.vnet.ibm.com
Cc: Pavel Emelianov <xemul@openvz.org>, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-Id: linux-mm.kvack.org

On Tue, Apr 8, 2008 at 12:05 AM, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>
> Paul Menage wrote:
>  > On Mon, Apr 7, 2008 at 11:52 PM, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>  >>  I agree, but like I said earlier, this was the easily available ready made
>  >>  application I found. Do you know of any other highly threaded micro benchmark?
>  >>
>  >
>  > How about a simple program that creates N threads that just sleep,
>  > then has the main thread exit?
>  >
>
>  That is not really representative of anything. I have that program handy. How do
>  we measure the impact on throughput?

It's very representative of how much additional overhead in terms of
mm->owner churn there is in a large multi-threaded application
exiting, which is the thing that you're trying to optimize with the
delayed thread group leader checks.

Paul
