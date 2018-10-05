Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id C29AA6B000A
	for <linux-mm@kvack.org>; Fri,  5 Oct 2018 15:02:46 -0400 (EDT)
Received: by mail-yb1-f198.google.com with SMTP id z14-v6so7140692ybp.6
        for <linux-mm@kvack.org>; Fri, 05 Oct 2018 12:02:46 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c129-v6sor4071828ybc.36.2018.10.05.12.02.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 05 Oct 2018 12:02:45 -0700 (PDT)
Subject: Re: [PATCH v2 0/3] mm: Fix for movable_node boot option
References: <20180925153532.6206-1-msys.mizuma@gmail.com>
 <alpine.DEB.2.21.1809272241130.8118@nanos.tec.linutronix.de>
 <20181002140111.GW18290@dhcp22.suse.cz>
From: Pavel Tatashin <pasha.tatashin@gmail.com>
Message-ID: <166980d0-03fc-382b-84a9-a7431dae1580@gmail.com>
Date: Fri, 5 Oct 2018 15:02:43 -0400
MIME-Version: 1.0
In-Reply-To: <20181002140111.GW18290@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Thomas Gleixner <tglx@linutronix.de>
Cc: Masayoshi Mizuma <msys.mizuma@gmail.com>, linux-mm@kvack.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Pavel Tatashin <pavel.tatashin@microsoft.com>, linux-kernel@vger.kernel.org, x86@kernel.org

I have not reviewed them yet. I am waiting for Masayoshi to send a new
series with correct order as Ingo requested.

Pavel

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
