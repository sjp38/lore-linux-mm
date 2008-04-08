From: "Paul Menage" <menage@google.com>
Subject: Re: [-mm] Add an owner to the mm_struct (v8)
Date: Mon, 7 Apr 2008 23:32:28 -0700
Message-ID: <6599ad830804072332w712e11f4j74a57769ac211389@mail.gmail.com>
References: <20080404080544.26313.38199.sendpatchset@localhost.localdomain>
	 <47F5F3FA.7060709@linux.vnet.ibm.com>
	 <6599ad830804041211r37848a6coaa900d8bdac40fbe@mail.gmail.com>
	 <47F79102.6090406@linux.vnet.ibm.com>
	 <6599ad830804051023v69caa3d4h6e26ccb420bca899@mail.gmail.com>
	 <47F7BB69.3000502@linux.vnet.ibm.com>
	 <6599ad830804051057n2f2802e4w6179f2e108467494@mail.gmail.com>
	 <47F7CC08.4090209@linux.vnet.ibm.com>
	 <6599ad830804051631g15363456s1952fda0bb4d395d@mail.gmail.com>
	 <47F86E4F.2080103@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753288AbYDHGcz@vger.kernel.org>
In-Reply-To: <47F86E4F.2080103@linux.vnet.ibm.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: balbir@linux.vnet.ibm.com
Cc: Pavel Emelianov <xemul@openvz.org>, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-Id: linux-mm.kvack.org

On Sat, Apr 5, 2008 at 11:31 PM, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>  > *If* they want to use the virtual address space controller, that is.
>  >
>  > By that argument, you should make the memory and cpu controllers the
>  > same controller, since in your scenario they'll usually be used
>  > together..
>
>  Heh, Virtual address and memory are more closely interlinked than CPU and Memory.

If you consider virtual address space limits a useful way to limit
swap usage, that's true.

But if you don't, then memory and CPU are more closely linked since
they represent real resource usage, whereas virtual address space is a
more abstract quantity.

Paul
