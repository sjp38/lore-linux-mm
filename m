References: <200511232333.jANNX9g23967@unix-os.sc.intel.com>
Message-ID: <cone.1132788946.360368.25446.501@kolivas.org>
From: Con Kolivas <kernel@kolivas.org>
Subject: Re: Kernel BUG at mm/rmap.c:491
Date: Thu, 24 Nov 2005 10:35:46 +1100
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; charset="US-ASCII"
Content-Disposition: inline
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: =?ISO-8859-1?B?Q2hlbiw=?= Kenneth W <kenneth.w.chen@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Chen, Kenneth W writes:

> Con Kolivas wrote on Wednesday, November 23, 2005 3:24 PM
>> Chen, Kenneth W writes:
>> 
>> > Has people seen this BUG_ON before?  On 2.6.15-rc2, x86-64.
>> > 
>> > Pid: 16500, comm: cc1 Tainted: G    B 2.6.15-rc2 #3
>> > 
>> > Pid: 16651, comm: sh Tainted: G    B 2.6.15-rc2 #3
>> 
>>                        ^^^^^^^^^^
>> 
>> Please try to reproduce it without proprietary binary modules linked in.
> 
> 
> ???, I'm not using any modules at all.
> 
> [albat]$ /sbin/lsmod
> Module                  Size  Used by
> [albat]$ 
> 
> 
> Also, isn't it 'P' indicate proprietary module, not 'G'?
> line 159: kernel/panic.c:
> 
>         snprintf(buf, sizeof(buf), "Tainted: %c%c%c%c%c%c",
>                 tainted & TAINT_PROPRIETARY_MODULE ? 'P' : 'G',

Sorry it's not proprietary module indeed. But what is tainting it?

Con

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
