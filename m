Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id EE3A36B0032
	for <linux-mm@kvack.org>; Mon,  8 Jun 2015 09:45:39 -0400 (EDT)
Received: by wiga1 with SMTP id a1so87061812wig.0
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 06:45:39 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gh2si1301582wib.11.2015.06.08.06.45.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 08 Jun 2015 06:45:38 -0700 (PDT)
Message-ID: <55759C81.4020005@suse.com>
Date: Mon, 08 Jun 2015 15:45:37 +0200
From: Juergen Gross <jgross@suse.com>
MIME-Version: 1.0
Subject: Re: [Xen-devel] [Patch V4 00/16] xen: support pv-domains larger than
 512GB
References: <1433765217-16333-1-git-send-email-jgross@suse.com> <55759BC8.50100@citrix.com>
In-Reply-To: <55759BC8.50100@citrix.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Vrabel <david.vrabel@citrix.com>, xen-devel@lists.xensource.com, konrad.wilk@oracle.com, boris.ostrovsky@oracle.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 06/08/2015 03:42 PM, David Vrabel wrote:
> On 08/06/15 13:06, Juergen Gross wrote:
>> Support 64 bit pv-domains with more than 512GB of memory.
>>
>> Tested with 64 bit dom0 on machines with 8GB and 1TB and 32 bit dom0 on a
>> 8GB machine. Conflicts between E820 map and different hypervisor populated
>> memory areas have been tested via a fake E820 map reserved area on the
>> 8GB machine.
>
> Do you have a git tree I can pull this from?

No, I don't. Sorry for that.

Juergen

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
