Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 968816B0023
	for <linux-mm@kvack.org>; Thu, 31 Jan 2013 17:10:37 -0500 (EST)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Thu, 31 Jan 2013 17:10:36 -0500
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 1039CC90044
	for <linux-mm@kvack.org>; Thu, 31 Jan 2013 17:10:32 -0500 (EST)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r0VMAVPK302278
	for <linux-mm@kvack.org>; Thu, 31 Jan 2013 17:10:31 -0500
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r0VM9vUl012322
	for <linux-mm@kvack.org>; Thu, 31 Jan 2013 15:09:58 -0700
Message-ID: <510AEBA9.8090804@linux.vnet.ibm.com>
Date: Thu, 31 Jan 2013 14:09:45 -0800
From: Dave Hansen <dave@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] rip out x86_32 NUMA remapping code
References: <20130131005616.1C79F411@kernel.stglabs.ibm.com> <510AE763.6090907@zytor.com> <CAE9FiQVn6_QZi3fNQ-JHYiR-7jeDJ5hT0SyT_+zVvfOj=PzF3w@mail.gmail.com> <510AE92B.8020605@zytor.com> <CAE9FiQUCB3CDB9kB6ojYRLHHjxgoRqmNFrcjkH1RNHjSHUZ4uQ@mail.gmail.com> <510AEA20.8040407@zytor.com>
In-Reply-To: <510AEA20.8040407@zytor.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Yinghai Lu <yinghai@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>

On 01/31/2013 02:03 PM, H. Peter Anvin wrote:
> That is arch-independent code, and the tile architecture still uses it.
> 
> Makes one wonder how much it will get tested going forward, especially
> with the x86-32 implementation clearly lacking in that department.

Yeah, I left the tile one because it wasn't obvious how it was being
used over there.  It _probably_ has the same bugs that x86 does.

I'll refresh the patch fixing some of the compile issues and resend.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
