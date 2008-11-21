Received: by ey-out-1920.google.com with SMTP id 21so564373eyc.44
        for <linux-mm@kvack.org>; Fri, 21 Nov 2008 11:55:56 -0800 (PST)
Message-ID: <eada2a070811211155r2fc18014o6f2f9e7e8105c66b@mail.gmail.com>
Date: Fri, 21 Nov 2008 11:55:56 -0800
From: "Tim Pepper" <lnxninja@linux.vnet.ibm.com>
Subject: Re: linux memory mgmt system question
In-Reply-To: <396532.97722.qm@web56504.mail.re3.yahoo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <396532.97722.qm@web56504.mail.re3.yahoo.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: cciontu@yahoo.com
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Nov 20, 2008 at 6:15 AM, Catalin CIONTU <cciontu@yahoo.com> wrote:
>> Hi,
>>
>> 1. Firstly, we want to know if 'free' is the best
>> tool that could give us the most accurate numbers with re to
>> used/free memory and swap. If not, what would be that tool
>> we could rely on?
>> 2. Are there any exceptions that may "fool" free
>> utility (inaccurate numbers would be returned), that we
>> would need to be aware of? For example, could things like
>> huge TLB pages being enabled have an impact on the numbers
>> reported by free utility?
>>
>> Could you please advise? Thanks a lot.

There is a lot of room for confusion and being fooled into wrong
conclusions in this space.  As per Christoph, it would be
interesting/helpful to know more about what you're trying to figure
out.

You might want to have a look at this wiki faq (and some of the other
pages on that wiki):
http://linux-mm.org/Low_On_Memory



Tim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
