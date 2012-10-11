Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 7E41E6B005D
	for <linux-mm@kvack.org>; Thu, 11 Oct 2012 13:59:38 -0400 (EDT)
Received: by mail-wg0-f45.google.com with SMTP id dq12so1424972wgb.26
        for <linux-mm@kvack.org>; Thu, 11 Oct 2012 10:59:36 -0700 (PDT)
Message-ID: <50770905.5070904@suse.cz>
Date: Thu, 11 Oct 2012 19:59:33 +0200
From: Jiri Slaby <jslaby@suse.cz>
MIME-Version: 1.0
Subject: Re: kswapd0: wxcessive CPU usage
References: <507688CC.9000104@suse.cz> <106695.1349963080@turing-police.cc.vt.edu>            <5076E700.2030909@suse.cz> <118079.1349978211@turing-police.cc.vt.edu>
In-Reply-To: <118079.1349978211@turing-police.cc.vt.edu>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Valdis.Kletnieks@vt.edu
Cc: Jiri Slaby <jirislaby@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On 10/11/2012 07:56 PM, Valdis.Kletnieks@vt.edu wrote:
> On Thu, 11 Oct 2012 17:34:24 +0200, Jiri Slaby said:
>> On 10/11/2012 03:44 PM, Valdis.Kletnieks@vt.edu wrote:
>>> So at least we know we're not hallucinating. :)
>> 
>> Just a thought? Do you have raid?
> 
> Nope, just a 160G laptop spinning hard drive. Filesystems are ext4
> on LVM on a cryptoLUKS partition on /dev/sda2.

Ok, it's maybe compaction. Do you have CONFIG_COMPACTION=y?


-- 
js
suse labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
