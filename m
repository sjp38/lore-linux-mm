Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 4F6DF6B0055
	for <linux-mm@kvack.org>; Sun, 12 Jul 2009 16:25:43 -0400 (EDT)
Message-ID: <4A5A4AF2.40609@redhat.com>
Date: Sun, 12 Jul 2009 23:43:30 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [Xen-devel] Re: [RFC PATCH 0/4] (Take 2): transcendent memory
 ("tmem") for Linux
References: <e60ab548-f0be-4a75-a10b-1f2eb89247a7@default>
In-Reply-To: <e60ab548-f0be-4a75-a10b-1f2eb89247a7@default>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: npiggin@suse.de, akpm@osdl.org, xen-devel@lists.xensource.com, tmem-devel@oss.oracle.com, kurt.hackel@oracle.com, Rusty Russell <rusty@rustcorp.com.au>, jeremy@goop.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, sunil.mushran@oracle.com, chris.mason@oracle.com, Anthony Liguori <anthony@codemonkey.ws>, Schwidefsky <schwidefsky@de.ibm.com>, dave.mccracken@oracle.com, Marcelo Tosatti <mtosatti@redhat.com>, alan@lxorguk.ukuu.org.uk, Balbir Singh <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On 07/12/2009 11:39 PM, Dan Magenheimer wrote:
>> Right, the transient uses of tmem when applied to disk objects
>> (swap/pagecache) are very similar to disk caches.  Which is
>> why you can
>> get a very similar effect when caching your virtual disks;
>> this can be
>> done without any guest modification.
>>      
>
> Write-through backing and virtual disk cacheing offer a
> similar effect, but it is far from the same.
>    

Can you explain how it differs for the swap case?  Maybe I don't 
understand how tmem preswap works.

-- 
I have a truly marvellous patch that fixes the bug which this
signature is too narrow to contain.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
