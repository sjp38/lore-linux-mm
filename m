Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f176.google.com (mail-ig0-f176.google.com [209.85.213.176])
	by kanga.kvack.org (Postfix) with ESMTP id 6D0FE6B0255
	for <linux-mm@kvack.org>; Wed, 30 Sep 2015 06:24:15 -0400 (EDT)
Received: by igbni9 with SMTP id ni9so27126003igb.0
        for <linux-mm@kvack.org>; Wed, 30 Sep 2015 03:24:15 -0700 (PDT)
Received: from DNVWSMAILOUT1.mcafee.com (dnvwsmailout1.mcafee.com. [161.69.31.173])
        by mx.google.com with ESMTPS id k4si12219478igu.50.2015.09.30.03.24.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Sep 2015 03:24:14 -0700 (PDT)
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 30 Sep 2015 10:24:02 +0000
From: MB McAfee SR Update <support_reply@McAfee.com>
Reply-To: MB McAfee SR Update <support_reply@McAfee.com>
Subject: RE: SR # <4-10997886031> Performance issues
Message-ID: <316c8443-14c6-459f-a69f-ed155c28d0f8@DNVEXAPP1N04.corpzone.internalzone.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: oleksandr.chernykh@playtech.com
Cc: linux-mm@kvack.org

Hello Oleksandr,

The node became unresponsive due to a system load of more than 50 and then it raises more and more until all queues are filled up. Please stop the machines and raise the memory and add addtional vCPUs and cores. This most limiting factor are the CPUs at the moment. 


With kind regards,

Intel Security Technical Support

International:  +1-888-847-8766
United Kingdom: 00800-6247-7463
Germany:	    00800-1225-5624 
Australia:      +1-800-073-267

Web: http://www.mcafee.com
Web: http://mysupport.mcafee.com

Please respond only to support_reply@mcafee.com, keeping "SR # <4-XXXXXXXXX>" with your respective service request number in the subject line.

Keep up-to-date on your McAfee products! Subscribe to McAfee's NEW Support Notification Service (SNS) to get timely technical info. 
Go to: http://my.mcafee.com/content/SNS_Subscription_Center

The information contained in this email message may be privileged, confidential and protected from disclosure. If you are not the intended recipient, any review, dissemination, distribution or copying is strictly prohibited. If you have received this email message in error, please notify the sender by reply email and delete the message and any attachments.


-----------------
From: MFE Support Outbound Profile
Sent: 09/30/2015 09:05:39
To: oleksandr.chernykh@playtech.com
Cc: linux-mm@kvack.org
Subject: RE: SR # <4-10997886031> Performance issues

Hello Oleksandr,

This is VMware. There are rcu stalls in the logs, which indicates that the VMs don't get enough CPU time assigned, the host might be overloaded or CPUs are overcommited. There are also network transmit timeouts in the logs, indicating the same.

The minimum memory for VMware is 16GB, please see the installation guide. The VMs only have 8GB assigned. Since there are load issues, I'd also suggest to assign more then the minimum CPU.


With kind regards,

Stefan Bluemel
Intel Security Technical Support

International:  +1-888-847-8766
United Kingdom: 00800-6247-7463
Germany:	    00800-1225-5624 
Australia:      +1-800-073-267

Web: http://www.mcafee.com
Web: http://mysupport.mcafee.com

Please respond only to support_reply@mcafee.com, keeping "SR # <4-XXXXXXXXX>" with your respective service request number in the subject line.

Keep up-to-date on your McAfee products! Subscribe to McAfee's NEW Support Notification Service (SNS) to get timely technical info. 
Go to: http://my.mcafee.com/content/SNS_Subscription_Center

The information contained in this email message may be privileged, confidential and protected from disclosure. If you are not the intended recipient, any review, dissemination, distribution or copying is strictly prohibited. If you have received this email message in error, please notify the sender by reply email and delete the message and any attachments.
-----------------
From: MFE Support Outbound Profile
Sent: 09/28/2015 07:30:17
To: oleksandr.chernykh@playtech.com
Cc: linux-mm@kvack.org
Subject: SR # <4-10997886031>  Performance issues

Hello Oleksandr,

Thank you for contacting Intel Security technical support.

I have escalated this SR together with the provided data to our development team. I could not figure out why the directory node (node 3) was so overloaded.

I will keep you updated on their findings.


With kind regards,

Stefan Bluemel
Intel Security Technical Support

International:  +1-888-847-8766
United Kingdom: 00800-6247-7463
Germany:	    00800-1225-5624 
Australia:      +1-800-073-267

Web: http://www.mcafee.com
Web: http://mysupport.mcafee.com

Please respond only to support_reply@mcafee.com, keeping "SR # <4-XXXXXXXXX>" with your respective service request number in the subject line.

Keep up-to-date on your McAfee products! Subscribe to McAfee's NEW Support Notification Service (SNS) to get timely technical info. 
Go to: http://my.mcafee.com/content/SNS_Subscription_Center

The information contained in this email message may be privileged, confidential and protected from disclosure. If you are not the intended recipient, any review, dissemination, distribution or copying is strictly prohibited. If you have received this email message in error, please notify the sender by reply email and delete the message and any attachments.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
