Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id B8CBF6B0025
	for <linux-mm@kvack.org>; Thu, 31 Jan 2013 17:13:04 -0500 (EST)
Message-ID: <510AEC68.2040500@zytor.com>
Date: Thu, 31 Jan 2013 14:12:56 -0800
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] rip out x86_32 NUMA remapping code
References: <20130131005616.1C79F411@kernel.stglabs.ibm.com> <510AE763.6090907@zytor.com> <CAE9FiQVn6_QZi3fNQ-JHYiR-7jeDJ5hT0SyT_+zVvfOj=PzF3w@mail.gmail.com> <510AE92B.8020605@zytor.com> <CAE9FiQUCB3CDB9kB6ojYRLHHjxgoRqmNFrcjkH1RNHjSHUZ4uQ@mail.gmail.com> <510AEA20.8040407@zytor.com> <510AEBA9.8090804@linux.vnet.ibm.com>
In-Reply-To: <510AEBA9.8090804@linux.vnet.ibm.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Yinghai Lu <yinghai@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>

On 01/31/2013 02:09 PM, Dave Hansen wrote:
> On 01/31/2013 02:03 PM, H. Peter Anvin wrote:
>> That is arch-independent code, and the tile architecture still uses it.
>>
>> Makes one wonder how much it will get tested going forward, especially
>> with the x86-32 implementation clearly lacking in that department.
> 
> Yeah, I left the tile one because it wasn't obvious how it was being
> used over there.  It _probably_ has the same bugs that x86 does.
> 
> I'll refresh the patch fixing some of the compile issues and resend.
> 

I already have fixup patches, I think.

	-hpa

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
