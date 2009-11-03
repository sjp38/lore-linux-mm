Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 2DAE36B004D
	for <linux-mm@kvack.org>; Tue,  3 Nov 2009 00:15:15 -0500 (EST)
Message-ID: <4AEFBC5E.7020300@redhat.com>
Date: Tue, 03 Nov 2009 07:15:10 +0200
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 01/11] Add shared memory hypercall to PV Linux guest.
References: <1257076590-29559-1-git-send-email-gleb@redhat.com> <1257076590-29559-2-git-send-email-gleb@redhat.com> <4AEECE2E.2050609@redhat.com> <20091102161809.GG27911@redhat.com>
In-Reply-To: <20091102161809.GG27911@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Gleb Natapov <gleb@redhat.com>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 11/02/2009 06:18 PM, Gleb Natapov wrote:
>>> +#define KVM_PV_SHM_VERSION 1
>>>        
>> versions = bad, feature bits = good
>>
>>      
> I have both! Do you want me to drop version?
>    

Yes.  Once a kernel is released you can't realistically change the version.

>> Some documentation for this?
>>
>> Also, the name should reflect the pv pagefault use.  For other uses
>> we can register other areas.
>>
>>      
> I wanted it to be generic, but I am fine with making it apf specific.
> It will allow to make it smaller too.
>    

Maybe we can squeeze it into the page-fault error code?

>> would solve this.  I prefer using put_user() though than a permanent
>> get_user_pages().
>>
>>      
> I want to prevent it from been swapped out.
>    

Since you don't prevent the page fault handler or code from being 
swapped out, you don't get anything out of it.

-- 
Do not meddle in the internals of kernels, for they are subtle and quick to panic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
