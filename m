Message-ID: <3C059728.8030205@zytor.com>
Date: Wed, 28 Nov 2001 18:02:16 -0800
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: Status of sendfile() + HIGHMEM
References: <3C0577FF.3040209@zytor.com> <3C05954B.9AC5B6BA@zip.com.au>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:

> "H. Peter Anvin" wrote:
> 
>>zeus.kernel.org is currently running with HIGHMEM turned off, since it
>>crashed due to an unfortunate interaction between sendfile() and HIGHMEM
>>-- this was using 2.4.10-ac4 or thereabouts.
>>
>>
> 
> What sort of NIC is it using?
> 

eepro100.

	-hpa

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
