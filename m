Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f44.google.com (mail-qa0-f44.google.com [209.85.216.44])
	by kanga.kvack.org (Postfix) with ESMTP id B7E236B0039
	for <linux-mm@kvack.org>; Wed,  4 Dec 2013 09:57:52 -0500 (EST)
Received: by mail-qa0-f44.google.com with SMTP id i13so6686532qae.3
        for <linux-mm@kvack.org>; Wed, 04 Dec 2013 06:57:52 -0800 (PST)
Received: from devils.ext.ti.com (devils.ext.ti.com. [198.47.26.153])
        by mx.google.com with ESMTPS id g3si27218738qaf.102.2013.12.04.06.57.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 04 Dec 2013 06:57:51 -0800 (PST)
Message-ID: <529F42E4.8080703@ti.com>
Date: Wed, 4 Dec 2013 09:57:40 -0500
From: Santosh Shilimkar <santosh.shilimkar@ti.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 06/23] mm/char: remove unnecessary inclusion of bootmem.h
References: <1386037658-3161-1-git-send-email-santosh.shilimkar@ti.com> <1386037658-3161-7-git-send-email-santosh.shilimkar@ti.com> <20131203225513.GV8277@htj.dyndns.org>
In-Reply-To: <20131203225513.GV8277@htj.dyndns.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Grygorii Strashko <grygorii.strashko@ti.com>, Yinghai Lu <yinghai@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

On Tuesday 03 December 2013 05:55 PM, Tejun Heo wrote:
> On Mon, Dec 02, 2013 at 09:27:21PM -0500, Santosh Shilimkar wrote:
>> From: Grygorii Strashko <grygorii.strashko@ti.com>
>>
>> Clean-up to remove depedency with bootmem headers.
>>
>> Cc: Yinghai Lu <yinghai@kernel.org>
>> Cc: Tejun Heo <tj@kernel.org>
>> Cc: Andrew Morton <akpm@linux-foundation.org>
>> Cc: Arnd Bergmann <arnd@arndb.de>
>> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
>> Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
>> Signed-off-by: Santosh Shilimkar <santosh.shilimkar@ti.com>
> 
> Please merge 4-6 into a single patch.
> 
Will do

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
