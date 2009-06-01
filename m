Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id D498A6B00C5
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 14:38:12 -0400 (EDT)
Message-ID: <4A241207.5050608@redhat.com>
Date: Mon, 01 Jun 2009 20:38:15 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] Warn if we run out of swap space
References: <alpine.DEB.1.10.0905221454460.7673@qirst.com> <4A23FF89.2060603@redhat.com> <alpine.DEB.1.10.0906011328410.3921@gentwo.org>
In-Reply-To: <alpine.DEB.1.10.0906011328410.3921@gentwo.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, Pavel Machek <pavel@ucw.cz>, Dave Hansen <dave@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Mon, 1 Jun 2009, Avi Kivity wrote:
>
>   
>> We really should have a machine readable channel for this sort of information,
>> so it can be plumbed to a userspace notification bubble the user can ignore.
>>     
>
> Good idea. Create an event for udev?
>   

Sounds good.  The event should fire some configurable time before we 
actually run out, since the userspace program will likely need to 
allocate memory.

It might even allocate more swap space, thus giving the machine more 
breathing room.

-- 
I have a truly marvellous patch that fixes the bug which this
signature is too narrow to contain.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
