Received: from zps78.corp.google.com (zps78.corp.google.com [172.25.146.78])
	by smtp-out.google.com with ESMTP id l6KKXsxD005319
	for <linux-mm@kvack.org>; Fri, 20 Jul 2007 13:33:54 -0700
Received: from wr-out-0506.google.com (wrai22.prod.google.com [10.54.60.22])
	by zps78.corp.google.com with ESMTP id l6KKXn4O027205
	for <linux-mm@kvack.org>; Fri, 20 Jul 2007 13:33:49 -0700
Received: by wr-out-0506.google.com with SMTP id i22so844933wra
        for <linux-mm@kvack.org>; Fri, 20 Jul 2007 13:33:49 -0700 (PDT)
Message-ID: <6599ad830707201333s527f20eeuc39424c7b79626@mail.gmail.com>
Date: Fri, 20 Jul 2007 13:33:48 -0700
From: "Paul Menage" <menage@google.com>
Subject: Re: [RFC][-mm PATCH 3/8] Memory controller accounting setup (v3)
In-Reply-To: <20070720082429.20752.63919.sendpatchset@balbir-laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070720082352.20752.37209.sendpatchset@balbir-laptop>
	 <20070720082429.20752.63919.sendpatchset@balbir-laptop>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Containers <containers@lists.osdl.org>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Dave Hansen <haveblue@us.ibm.com>, Linux MM Mailing List <linux-mm@kvack.org>, Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>, Pavel Emelianov <xemul@openvz.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Eric W Biederman <ebiederm@xmission.com>
List-ID: <linux-mm.kvack.org>

On 7/20/07, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> +       mem = mem_container_from_cont(task_container(p,
> +                                       mem_container_subsys_id));
> +       css_get(&mem->css);

The container framework won't try to free a subsystem's root container
state, so this isn't needed.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
