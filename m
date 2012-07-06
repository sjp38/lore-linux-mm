Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id BAFE66B0062
	for <linux-mm@kvack.org>; Fri,  6 Jul 2012 01:46:55 -0400 (EDT)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <shangw@linux.vnet.ibm.com>;
	Fri, 6 Jul 2012 01:46:45 -0400
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 4CC4038C803A
	for <linux-mm@kvack.org>; Fri,  6 Jul 2012 01:46:44 -0400 (EDT)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q665kiih371018
	for <linux-mm@kvack.org>; Fri, 6 Jul 2012 01:46:44 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q665khJ7010070
	for <linux-mm@kvack.org>; Fri, 6 Jul 2012 01:46:44 -0400
Date: Fri, 6 Jul 2012 13:46:39 +0800
From: Gavin Shan <shangw@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm/buddy: more comments for skip_free_areas_node()
Message-ID: <20120706054639.GA32570@shangw>
Reply-To: Gavin Shan <shangw@linux.vnet.ibm.com>
References: <1341545097-9933-1-git-send-email-shangw@linux.vnet.ibm.com>
 <CAM_iQpUQN0EEFf5G3RMiR5_51-Pfm2n1kqtQhRuTjQz-wvsmjw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAM_iQpUQN0EEFf5G3RMiR5_51-Pfm2n1kqtQhRuTjQz-wvsmjw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Cc: Gavin Shan <shangw@linux.vnet.ibm.com>, linux-mm@kvack.org, akpm@linux-foundation.org

On Fri, Jul 06, 2012 at 01:42:39PM +0800, Cong Wang wrote:
>On Fri, Jul 6, 2012 at 11:24 AM, Gavin Shan <shangw@linux.vnet.ibm.com> wrote:
>> The initial idea comes from Cong Wang. We're running out of memory
>> while calling function skip_free_areas_node(). So it would be unsafe
>> to allocate more memory from either stack or heap. The patche adds
>> more comments to address that.
>
>I think these comments should add to show_free_areas(),
>not skip_free_areas_node().
>

aha, exactly. Thanks a lot, Cong.

Thanks,
Gavin

>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
