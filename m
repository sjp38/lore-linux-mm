Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id A1FBA6B02F3
	for <linux-mm@kvack.org>; Wed,  7 Jun 2017 05:05:41 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id w79so717610wme.7
        for <linux-mm@kvack.org>; Wed, 07 Jun 2017 02:05:41 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id t2si1197391wrb.3.2017.06.07.02.05.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Jun 2017 02:05:40 -0700 (PDT)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5793gTA091115
	for <linux-mm@kvack.org>; Wed, 7 Jun 2017 05:05:38 -0400
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2awy7mv1vt-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 07 Jun 2017 05:05:38 -0400
Received: from localhost
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <wild@linux.vnet.ibm.com>;
	Wed, 7 Jun 2017 10:05:35 +0100
From: Andre Wild <wild@linux.vnet.ibm.com>
Subject: BUG: using __this_cpu_read() in preemptible [00000000] code:
 mm_percpu_wq/7
Date: Wed, 7 Jun 2017 11:05:32 +0200
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Message-Id: <b7cc8709-5bbf-8a9a-a155-0ea804641e9a@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, heiko.carstens@de.ibm.com

Hi Christoph,

I'm currently seeing the following message running kernel version 4.11.0.
It looks like it was introduced with the patch 4037d452202e34214e8a939fa5621b2b3bbb45b7.
Can you please take a look at this problem?

[Tue Jun  6 15:27:03 2017] BUG: using __this_cpu_read() in preemptible [00000000] code: mm_percpu_wq/7
[Tue Jun  6 15:27:03 2017] caller is refresh_cpu_vm_stats+0x198/0x3d8
[Tue Jun  6 15:27:03 2017] CPU: 0 PID: 7 Comm: mm_percpu_wq Tainted: G        W       4.11.0-20170529.0.ae409ab.224a322.fc25.s390xdefault #1
[Tue Jun  6 15:27:03 2017] Workqueue: mm_percpu_wq vmstat_update
[Tue Jun  6 15:27:03 2017] Call Trace:
[Tue Jun  6 15:27:03 2017] ([<00000000001138ea>] show_trace+0x8a/0xe0)
[Tue Jun  6 15:27:03 2017]  [<00000000001139c0>] show_stack+0x80/0xd8
[Tue Jun  6 15:27:03 2017]  [<000000000074488e>] dump_stack+0x96/0xd8
[Tue Jun  6 15:27:03 2017]  [<000000000077afaa>] check_preemption_disabled+0xea/0x108
[Tue Jun  6 15:27:03 2017]  [<00000000002ec198>] refresh_cpu_vm_stats+0x198/0x3d8
[Tue Jun  6 15:27:03 2017]  [<00000000002ed306>] vmstat_update+0x2e/0x98
[Tue Jun  6 15:27:03 2017]  [<0000000000167450>] process_one_work+0x3d8/0x780
[Tue Jun  6 15:27:03 2017]  [<00000000001688dc>] rescuer_thread+0x224/0x3d0
[Tue Jun  6 15:27:03 2017]  [<0000000000170096>] kthread+0x166/0x178
[Tue Jun  6 15:27:03 2017]  [<0000000000a4d69a>] kernel_thread_starter+0x6/0xc
[Tue Jun  6 15:27:03 2017]  [<0000000000a4d694>] kernel_thread_starter+0x0/0xc
[Tue Jun  6 15:27:03 2017] INFO: lockdep is turned off.


Kind regards,

AndrA(C)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
