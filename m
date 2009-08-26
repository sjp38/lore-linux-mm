From: Yohan <kernel@yohan.staff.proxad.net>
Subject: Re: VM issue causing high CPU loads
Date: Wed, 26 Aug 2009 13:53:58 +0200
Message-ID: <4A952256.2030602@yohan.staff.proxad.net>
References: <4A92A25A.4050608@yohan.staff.proxad.net> <20090824162155.ce323f08.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756832AbZHZLyD@vger.kernel.org>
In-Reply-To: <20090824162155.ce323f08.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-Id: linux-mm.kvack.org

Andrew Morton wrote:
> On Mon, 24 Aug 2009 16:23:22 +0200
> Yohan <kernel@yohan.staff.proxad.net> wrote:
>   
>> Hi,
>>
>>     Is someone have an idea for that :
>>
>>         http://bugzilla.kernel.org/show_bug.cgi?id=14024
>>     
> Please generate a kernel profile to work out where all the CPU tie is
> being spent.  Documentation/basic_profiling.txt is a starting point.
I did & post the profiles on the bugtrack
I dit it with a 2.6.31-rc7-git2 kernel
(need at least 2 week days after a reboot/drop_cache  to really show the 
bug)

Thanks
