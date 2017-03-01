Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9D0296B0389
	for <linux-mm@kvack.org>; Wed,  1 Mar 2017 12:31:38 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id w37so19676677wrc.2
        for <linux-mm@kvack.org>; Wed, 01 Mar 2017 09:31:38 -0800 (PST)
Received: from one.firstfloor.org (one.firstfloor.org. [193.170.194.197])
        by mx.google.com with ESMTPS id p51si7382401wrb.250.2017.03.01.09.31.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Mar 2017 09:31:37 -0800 (PST)
Date: Wed, 1 Mar 2017 09:31:36 -0800
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH v2 1/3] sparc64: NG4 memset 32 bits overflow
Message-ID: <20170301173136.GI26852@two.firstfloor.org>
References: <1488327283-177710-1-git-send-email-pasha.tatashin@oracle.com>
 <1488327283-177710-2-git-send-email-pasha.tatashin@oracle.com>
 <87h93dhmir.fsf@firstfloor.org>
 <70b638b0-8171-ffce-c0c5-bdcbae3c7c46@oracle.com>
 <20170301151910.GH26852@two.firstfloor.org>
 <6a26815d-0ec2-7922-7202-b1e17d58aa00@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6a26815d-0ec2-7922-7202-b1e17d58aa00@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pasha Tatashin <pasha.tatashin@oracle.com>
Cc: Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org, sparclinux@vger.kernel.org

On Wed, Mar 01, 2017 at 11:34:10AM -0500, Pasha Tatashin wrote:
> Hi Andi,
> 
> Thank you for your comment, I am thinking to limit the default
> maximum hash tables sizes to 512M.
> 
> If it is bigger than 512M, we would still need my patch to improve

Even 512MB seems too large. I wouldn't go larger than a few tens
of MB, maybe 32MB.

Also you would need to cover all the big hashes.

The most critical ones are likely the network hash tables, these
maybe be a bit larger (but certainly also not 0.5TB) 

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
