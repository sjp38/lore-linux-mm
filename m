Message-ID: <47C3D64A.6080709@cn.fujitsu.com>
Date: Tue, 26 Feb 2008 17:05:14 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] Memory Resource Controller Add Boot Option
References: <20080225115509.23920.66231.sendpatchset@localhost.localdomain>	 <20080225115550.23920.43199.sendpatchset@localhost.localdomain>	 <6599ad830802250816m1f83dbeekbe919a60d4b51157@mail.gmail.com>	 <47C2F86A.9010709@linux.vnet.ibm.com>	 <6599ad830802250932s5eaa3bcchbfc49fe0e76d3f7d@mail.gmail.com>	 <47C2FCC1.7090203@linux.vnet.ibm.com> <47C30EDC.4060005@google.com>	 <47C38127.2000109@cn.fujitsu.com> <6599ad830802260058m28d8f46djc83f47e19e2946a7@mail.gmail.com>
In-Reply-To: <6599ad830802260058m28d8f46djc83f47e19e2946a7@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>
Cc: balbir@linux.vnet.ibm.com, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Paul Menage wrote:
> On Mon, Feb 25, 2008 at 7:01 PM, Li Zefan <lizf@cn.fujitsu.com> wrote:
>>  >
>>  > - foo doesn't show up in /proc/cgroups
>>
>>  Or we can print out the disable flag, maybe this will be better?
>>  Because we can distinguish from disabled and not compiled in from
>>
>> /proc/cgroups.
> 
> Certainly possible, if people felt it was useful.
> 
>>  > - foo isn't auto-mounted if you mount all cgroups in a single hierarchy
>>  > - foo isn't visible as an individually mountable subsystem
>>
>>  You mentioned in a previous mail if we mount a disabled subsystem we
>>  will get an error. Here we just ignore the mount option. Which makes
>>  more sense ?
>>
> 
> No, we don't ignore the mount option - we give an error since it
> doesn't refer to a valid subsystem. (And in the first case there is no
> mount option).
> 

You are write, -ENOENT will be returned in this case. I made a mistake when
reading the prototype patch, thanks for the clarification. :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
