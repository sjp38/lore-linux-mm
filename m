Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2CA356B0003
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 22:34:55 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id g73-v6so216127wmc.5
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 19:34:55 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id k40-v6si2431265eda.213.2018.06.07.19.34.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jun 2018 19:34:54 -0700 (PDT)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w582TFLM077733
	for <linux-mm@kvack.org>; Thu, 7 Jun 2018 22:34:52 -0400
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2jfgqkgtdx-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 07 Jun 2018 22:34:51 -0400
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <linuxram@us.ibm.com>;
	Fri, 8 Jun 2018 03:34:49 +0100
Date: Thu, 7 Jun 2018 19:34:41 -0700
From: Ram Pai <linuxram@us.ibm.com>
Subject: Re: pkeys on POWER: Access rights not reset on execve
Reply-To: Ram Pai <linuxram@us.ibm.com>
References: <20180520060425.GL5479@ram.oc3035372033.ibm.com>
 <CALCETrVvQkphypn10A_rkX35DNqi29MJcXYRpRiCFNm02VYz2g@mail.gmail.com>
 <20180520191115.GM5479@ram.oc3035372033.ibm.com>
 <aae1952c-886b-cfc8-e98b-fa3be5fab0fa@redhat.com>
 <20180603201832.GA10109@ram.oc3035372033.ibm.com>
 <4e53b91f-80a7-816a-3e9b-56d7be7cd092@redhat.com>
 <20180604140135.GA10088@ram.oc3035372033.ibm.com>
 <f2f61c24-8e8f-0d36-4e22-196a2a3f7ca7@redhat.com>
 <20180604190229.GB10088@ram.oc3035372033.ibm.com>
 <30040030-1aa2-623b-beec-dd1ceb3eb9a7@redhat.com>
MIME-Version: 1.0
In-Reply-To: <30040030-1aa2-623b-beec-dd1ceb3eb9a7@redhat.com>
Message-Id: <20180608023441.GA5573@ram.oc3035372033.ibm.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Florian Weimer <fweimer@redhat.com>
Cc: Linux-MM <linux-mm@kvack.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>

> 
> So the remaining question at this point is whether the Intel
> behavior (default-deny instead of default-allow) is preferable.

Florian, remind me what behavior needs to fixed? 

-- 
Ram Pai
