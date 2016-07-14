Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id 97FFA6B0005
	for <linux-mm@kvack.org>; Thu, 14 Jul 2016 13:07:56 -0400 (EDT)
Received: by mail-yw0-f197.google.com with SMTP id c124so58149364ywd.1
        for <linux-mm@kvack.org>; Thu, 14 Jul 2016 10:07:56 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t10si1571595ywa.244.2016.07.14.10.07.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Jul 2016 10:07:55 -0700 (PDT)
Subject: Re: System freezes after OOM
References: <57837CEE.1010609@redhat.com>
 <f80dc690-7e71-26b2-59a2-5a1557d26713@redhat.com>
 <9be09452-de7f-d8be-fd5d-4a80d1cd1ba3@redhat.com>
 <alpine.LRH.2.02.1607111027080.14327@file01.intranet.prod.int.rdu2.redhat.com>
 <20160712064905.GA14586@dhcp22.suse.cz>
 <alpine.LRH.2.02.1607121907160.24806@file01.intranet.prod.int.rdu2.redhat.com>
 <20160713111006.GF28723@dhcp22.suse.cz>
 <alpine.LRH.2.02.1607131021410.31769@file01.intranet.prod.int.rdu2.redhat.com>
 <20160714125129.GA12289@dhcp22.suse.cz>
 <740b17f0-e1bb-b021-e9e1-ad6dcf5f033a@redhat.com>
 <20160714153120.GD12289@dhcp22.suse.cz>
From: Ondrej Kozina <okozina@redhat.com>
Message-ID: <9ca3459a-8226-b870-163e-58e2bb10df74@redhat.com>
Date: Thu, 14 Jul 2016 19:07:52 +0200
MIME-Version: 1.0
In-Reply-To: <20160714153120.GD12289@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Mikulas Patocka <mpatocka@redhat.com>, Jerome Marchand <jmarchan@redhat.com>, Stanislav Kozina <skozina@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, dm-devel@redhat.com

On 07/14/2016 05:31 PM, Michal Hocko wrote:
> On Thu 14-07-16 16:08:28, Ondrej Kozina wrote:
> [...]
>> As Mikulas pointed out, this doesn't work. The system froze as well with the
>> patch above. Will try to tweak the patch with Mikulas's suggestion...
>
> Thank you for testing! Do you happen to have traces of the frozen
> processes? Does the flusher still gets throttled because the bias it
> gets is not sufficient. Or does it get throttled at a different place?
>

Sure. Here it is (including sysrq+t and sysrq+w output): 
https://okozina.fedorapeople.org/bugs/swap_on_dmcrypt/4.7.0-rc7+/1/4.7.0-rc7+.log

In a directory with the log there's also a patch the kernel was compiled 
with.

Ondra

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
