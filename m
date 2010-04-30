Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 06FE36003C2
	for <linux-mm@kvack.org>; Fri, 30 Apr 2010 03:13:53 -0400 (EDT)
Message-ID: <4BDA8324.7090409@redhat.com>
Date: Fri, 30 Apr 2010 10:13:40 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: Frontswap [PATCH 0/4] (was Transcendent Memory): overview
References: <4BD16D09.2030803@redhat.com>	 <b01d7882-1a72-4ba9-8f46-ba539b668f56@default>	 <4BD1A74A.2050003@redhat.com>	 <4830bd20-77b7-46c8-994b-8b4fa9a79d27@default>	 <4BD1B427.9010905@redhat.com> <4BD1B626.7020702@redhat.com>	 <5fa93086-b0d7-4603-bdeb-1d6bfca0cd08@default>	 <4BD3377E.6010303@redhat.com>	 <1c02a94a-a6aa-4cbb-a2e6-9d4647760e91@default4BD43033.7090706@redhat.com>	 <ce808441-fae6-4a33-8335-f7702740097a@default>	 <20100428055538.GA1730@ucw.cz> <1272591924.23895.807.camel@nimitz>
In-Reply-To: <1272591924.23895.807.camel@nimitz>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Pavel Machek <pavel@ucw.cz>, Dan Magenheimer <dan.magenheimer@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, hugh.dickins@tiscali.co.uk, ngupta@vflare.org, JBeulich@novell.com, chris.mason@oracle.com, kurt.hackel@oracle.com, dave.mccracken@oracle.com, npiggin@suse.de, akpm@linux-foundation.org, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On 04/30/2010 04:45 AM, Dave Hansen wrote:
>
> A large portion of CMM2's gain came from the fact that you could take
> memory away from guests without _them_ doing any work.  If the system is
> experiencing a load spike, you increase load even more by making the
> guests swap.  If you can just take some of their memory away, you can
> smooth that spike out.  CMM2 and frontswap do that.  The guests
> explicitly give up page contents that the hypervisor does not have to
> first consult with the guest before discarding.
>    

Frontswap does not do this.  Once a page has been frontswapped, the host 
is committed to retaining it until the guest releases it.  It's really 
not very different from a synchronous swap device.

I think cleancache allows the hypervisor to drop pages without the 
guest's immediate knowledge, but I'm not sure.

-- 
I have a truly marvellous patch that fixes the bug which this
signature is too narrow to contain.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
