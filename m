Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3A2AE6B0069
	for <linux-mm@kvack.org>; Tue, 21 Nov 2017 17:16:33 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id s11so14093713pgc.13
        for <linux-mm@kvack.org>; Tue, 21 Nov 2017 14:16:33 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id j12si7220461pgf.678.2017.11.21.14.16.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Nov 2017 14:16:32 -0800 (PST)
Subject: Re: [PATCH 17/30] x86, kaiser: map debug IDT tables
References: <20171110193058.BECA7D88@viggo.jf.intel.com>
 <20171110193138.1185728D@viggo.jf.intel.com>
 <alpine.DEB.2.20.1711202139240.2348@nanos>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <f755f175-308b-7d7e-d3bb-3f538cdf075c@linux.intel.com>
Date: Tue, 21 Nov 2017 14:16:27 -0800
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1711202139240.2348@nanos>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org

On 11/20/2017 12:40 PM, Thomas Gleixner wrote:
> On Fri, 10 Nov 2017, Dave Hansen wrote:
>>  
>> +static int kaiser_user_map_ptr_early(const void *start_addr, unsigned long size,
>> +				 unsigned long flags)
>> +{
>> +	int ret = kaiser_add_user_map(start_addr, size, flags);
>> +	WARN_ON(ret);
>> +	return ret;
> What's the point of the return value when it is ignored at the call site?

I'm dropping this patch, btw.  It was unnecessary.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
