From: Pavel Tatashin <pavel.tatashin@microsoft.com>
Subject: Re: [PATCH v2 0/3] mm: Fix for movable_node boot option
Date: Fri, 5 Oct 2018 14:57:02 -0400
Message-ID: <0e9b7c25-8e84-e37a-ce65-671641210aab@gmail.com>
References: <20180925153532.6206-1-msys.mizuma@gmail.com>
 <alpine.DEB.2.21.1809272241130.8118@nanos.tec.linutronix.de>
 <20181002140111.GW18290@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20181002140111.GW18290@dhcp22.suse.cz>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
To: Michal Hocko <mhocko@kernel.org>, Thomas Gleixner <tglx@linutronix.de>
Cc: Masayoshi Mizuma <msys.mizuma@gmail.com>, linux-mm@kvack.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel@vger.kernel.org, x86@kernel.org
List-Id: linux-mm.kvack.org


On 10/2/18 10:01 AM, Michal Hocko wrote:
> On Thu 27-09-18 22:41:36, Thomas Gleixner wrote:
>> On Tue, 25 Sep 2018, Masayoshi Mizuma wrote:
>>
>>> This patch series are the fix for movable_node boot option
>>> issue which was introduced by commit 124049decbb1 ("x86/e820:
>>> put !E820_TYPE_RAM regions into memblock.reserved").
>>>
>>> First patch, revert the commit. Second and third patch fix the
>>> original issue.
>>
>> Can the mm folks please comment on this?
> 
> I was under impression that Pavel who authored the original change which
> got reverted here has reviewed these patches.
> 

I have not reviewed them yet. I am waiting for Masayoshi to send a new
series with correct order as Ingo requested.

Pavel
