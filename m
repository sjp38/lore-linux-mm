Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4DD922802FE
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 21:13:22 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id u19so94152185qtc.14
        for <linux-mm@kvack.org>; Thu, 27 Jul 2017 18:13:22 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id k14si8477036qtg.204.2017.07.27.18.13.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Jul 2017 18:13:21 -0700 (PDT)
Subject: Re: [RESEND PATCH 1/2] userfaultfd: Add feature to request for a
 signal delivery
References: <1500958062-953846-1-git-send-email-prakash.sangappa@oracle.com>
 <1500958062-953846-2-git-send-email-prakash.sangappa@oracle.com>
 <20170727115854.GA27766@dhcp22.suse.cz>
From: Prakash Sangappa <prakash.sangappa@oracle.com>
Message-ID: <951e1187-4d8e-13a7-f471-2d863a37788c@oracle.com>
Date: Thu, 27 Jul 2017 18:13:13 -0700
MIME-Version: 1.0
In-Reply-To: <20170727115854.GA27766@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, aarcange@redhat.com, rppt@linux.vnet.ibm.com, akpm@linux-foundation.org, mike.kravetz@oracle.com

Yes, I will provide a man page update.

-Prakash.


On 7/27/17 4:58 AM, Michal Hocko wrote:
> Please do not forget to provide a man page update with clarified
> semantic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
