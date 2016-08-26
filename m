Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 60A1A830BE
	for <linux-mm@kvack.org>; Fri, 26 Aug 2016 16:17:34 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id i27so171193167qte.3
        for <linux-mm@kvack.org>; Fri, 26 Aug 2016 13:17:34 -0700 (PDT)
Received: from mx04-000ceb01.pphosted.com (mx0b-000ceb01.pphosted.com. [67.231.152.126])
        by mx.google.com with ESMTPS id i52si15622201qti.20.2016.08.26.13.17.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Aug 2016 13:17:33 -0700 (PDT)
Subject: Re: OOM detection regressions since 4.7
References: <20160822093249.GA14916@dhcp22.suse.cz>
 <20160822093707.GG13596@dhcp22.suse.cz> <20160822100528.GB11890@kroah.com>
 <20160822105441.GH13596@dhcp22.suse.cz> <20160822133114.GA15302@kroah.com>
 <20160822134227.GM13596@dhcp22.suse.cz>
 <20160822150517.62dc7cce74f1af6c1f204549@linux-foundation.org>
 <20160823074339.GB23577@dhcp22.suse.cz>
 <5852cd26-e013-8313-30f0-68a92db02b8f@Quantum.com>
 <20160826062556.GA16195@dhcp22.suse.cz>
From: Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>
Message-ID: <105b914b-7846-9be6-800e-a8740e9bef4f@Quantum.com>
Date: Fri, 26 Aug 2016 13:17:19 -0700
MIME-Version: 1.0
In-Reply-To: <20160826062556.GA16195@dhcp22.suse.cz>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Markus Trippelsdorf <markus@trippelsdorf.de>, Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>, Jiri Slaby <jslaby@suse.com>, Olaf Hering <olaf@aepfle.de>, Greg KH <gregkh@linuxfoundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <js1304@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 25.08.2016 23:26, Michal Hocko wrote:
> On Thu 25-08-16 13:30:23, Ralf-Peter Rohbeck wrote:
> [...]
>> This worked for me for about 12 hours of my torture test. Logs are at
>> https://urldefense.proofpoint.com/v2/url?u=https-3A__filebin.net_2rfah407nbhzs69e_OOM-5F4.8.0-2Drc2-5Fp1.tar.bz2&d=DQIBAg&c=8S5idjlO_n28Ko3lg6lskTMwneSC-WqZ5EBTEEvDlkg&r=yGQdEpZknbtYvR0TyhkCGu-ifLklIvXIf740poRFltQ&m=xBE9zOUuzzrfyIgW70g1kmSzqiGPNXjBnN_zvF4eStQ&s=jdGSxmrQNhIx4cjVDsyyAA0K83hANgWXu1aFBDh_1B4&e= .
> Thanks! Can we add your
> Tested-by: Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>
>
> to the patch?

Sure.


Ralf-Peter


----------------------------------------------------------------------
The information contained in this transmission may be confidential. Any disclosure, copying, or further distribution of confidential information is not permitted unless such privilege is explicitly granted in writing by Quantum. Quantum reserves the right to have electronic communications, including email and attachments, sent across its networks filtered through anti virus and spam software programs and retain such messages in order to comply with applicable data security and retention requirements. Quantum is not responsible for the proper and complete transmission of the substance of this communication or for any delay in its receipt.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
