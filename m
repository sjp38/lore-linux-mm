Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 521A26B0038
	for <linux-mm@kvack.org>; Thu,  8 Oct 2015 05:23:42 -0400 (EDT)
Received: by pablk4 with SMTP id lk4so49720368pab.3
        for <linux-mm@kvack.org>; Thu, 08 Oct 2015 02:23:42 -0700 (PDT)
Received: from DNVWSMAILOUT1.mcafee.com (dnvwsmailout1.mcafee.com. [161.69.31.173])
        by mx.google.com with ESMTPS id wk3si65022278pab.93.2015.10.08.02.23.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Oct 2015 02:23:41 -0700 (PDT)
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 8 Oct 2015 09:18:50 +0000
From: MB McAfee SR Update <support_reply@McAfee.com>
Reply-To: MB McAfee SR Update <support_reply@McAfee.com>
Subject: RE: SR # <4-10997886031> Performance issues
Message-ID: <058cbccd-fafe-4664-b85f-e498a198d658@DNVEXAPP1N04.corpzone.internalzone.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: oleksandr.chernykh@playtech.com
Cc: linux-mm@kvack.org

Hello Oleksandr,

I also recommend different director priorities for the cluster members. Currently all are on 75. Better is 90 - 60 - 30


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
Sent: 10/08/2015 09:20:35
To: oleksandr.chernykh@playtech.com
Cc: linux-mm@kvack.org
Subject: RE: SR # <4-10997886031> Performance issues

Hello Oleksandr,

We see that the current director can't find scanning nodes and that's the reason why it handles the traffic on his own until it is overloaded. 

Do you have more information about the different nodes? Are all of them on the same VMware host?

Do you use overprovisioning/oversubscription for these hosts - this is highly not recommended.

The issue is caused due to non-working Proxy HA - the settings seem to work - I don't see any mis-configuration, but due to so many issues I would recommend a cluster split and new HA setup from scratch:
https://community.mcafee.com/docs/DOC-4819


I also recommend some tcpdumps for VRRP traffic and for port 253 (Filters: ip.proto eq 253, vrrp)


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
Sent: 10/08/2015 06:20:30
To: oleksandr.chernykh@playtech.com
Cc: linux-mm@kvack.org
Subject: RE: SR # <4-10997886031> Performance issues

Hello Oleksandr,

I hope you are doing well.

I have a short update from development. Due to some research we have found the following:

Oct  2 10:28:16 ua-is-proxy-1 kernel: [141521.487780] TX Too many directors in too short a time delaying
Oct  2 10:28:16 ua-is-proxy-1 kernel: [141521.487781]  172.29.50.103
Oct  2 10:28:17 ua-is-proxy-1 kernel: [141522.486814] TX Too many directors in too short a time delaying
Oct  2 10:28:17 ua-is-proxy-1 kernel: [141522.486816]  172.29.50.103

Oct  2 10:50:26 ua-is-proxy-2 Keepalived_vrrp[28016]: VRRP_Instance(VI_1) Transition to MASTER STATE
Oct  2 10:50:26 ua-is-proxy-2 Keepalived_vrrp[28016]: VRRP_Instance(VI_1) Received higher prio advert
Oct  2 10:50:26 ua-is-proxy-2 Keepalived_vrrp[28016]: VRRP_Instance(VI_1) Entering BACKUP STATE
Oct  2 10:57:26 ua-is-proxy-2 Keepalived_vrrp[28016]: VRRP_Instance(VI_1) Transition to MASTER STATE
Oct  2 10:57:27 ua-is-proxy-2 Keepalived_vrrp[28016]: VRRP_Instance(VI_1) Received higher prio advert
Oct  2 10:57:27 ua-is-proxy-2 Keepalived_vrrp[28016]: VRRP_Instance(VI_1) Entering BACKUP STATE
Oct  2 10:58:31 ua-is-proxy-2 Keepalived_vrrp[28016]: VRRP_Instance(VI_1) Transition to MASTER STATE
Oct  2 10:58:32 ua-is-proxy-2 Keepalived_vrrp[28016]: VRRP_Instance(VI_1) Entering MASTER STATE
Oct  2 10:58:33 ua-is-proxy-2 Keepalived_vrrp[28016]: VRRP_Instance(VI_1) Received higher prio advert
Oct  2 10:58:33 ua-is-proxy-2 Keepalived_vrrp[28016]: VRRP_Instance(VI_1) Entering BACKUP STATE
Oct  2 10:58:42 ua-is-proxy-2 Keepalived_vrrp[28016]: VRRP_Instance(VI_1) Transition to MASTER STATE
....


There is still instability in the network. In case scanning nodes fails all IPs that still have traffic will
create sticky table entries on the director, which will only go away if there is no traffic for some time. That probably explains why the director got more traffic.

So next thing would be to solve the network issue.


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
Sent: 10/06/2015 08:11:45
To: oleksandr.chernykh@playtech.com
Cc: linux-mm@kvack.org
Subject: RE: SR # <4-10997886031> Performance issues

Hello Oleksandr,

The 3rd node is currently the director node and will have more connections because it receives all incoming connections:

https://community.mcafee.com/docs/DOC-4819

The load has reduced, but is still too high:

Load on machine when feedback was done:load average: 25.65, 27.69, 26.05; number of threads running or waiting per core: 4.27, 4.62, 4.34


I will update development with the new data and let you know.


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
Sent: 10/02/2015 07:35:51
To: oleksandr.chernykh@playtech.com
Cc: linux-mm@kvack.org
Subject: RE: SR # <4-10997886031> Performance issues

Hello Oleksandr,

I hope you are doing well.

Do you see any change in the load after raising the CPUs and the memory? 

When you have an opportunity could you let me know if you have any updates on progress of your outstanding service request? If you need any assistance please don't hesitate to contact me. 


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
Sent: 09/30/2015 12:19:54
To: oleksandr.chernykh@playtech.com
Cc: linux-mm@kvack.org
Subject: RE: SR # <4-10997886031> Performance issues

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
