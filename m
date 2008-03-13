Message-ID: <47D9BAA6.4010409@cn.fujitsu.com>
Date: Fri, 14 Mar 2008 08:37:10 +0900
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/3] memcgoup: allow memory.failcnt to be reset
References: <47D65A3E.100@cn.fujitsu.com> <20080311191649.32a2cbae.kamezawa.hiroyu@jp.fujitsu.com> <47D65B99.3070208@linux.vnet.ibm.com>
In-Reply-To: <47D65B99.3070208@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Paul Menage <menage@google.com>, Pavel Emelianov <xemul@openvz.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Linux Containers <containers@lists.osdl.org>
List-ID: <linux-mm.kvack.org>

Balbir Singh wrote:
> KAMEZAWA Hiroyuki wrote:
>> On Tue, 11 Mar 2008 19:09:02 +0900
>> Li Zefan <lizf@cn.fujitsu.com> wrote:
>>
>>> Allow memory.failcnt to be reset to 0:
>>>
>>>         echo 0 > memory.failcnt
>>>
>>> And '0' is the only valid value.
>>>
>> Can't this be generic resource counter function ?
>>
> 
> I was about to suggest a generic cgroup option, since we do reset values even
> for the cpu accounting subsystem.
> 

It won't help. You still have to write the write function, and you have to call
some res_counter routines to reset the value, and maybe also do some other
work.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
