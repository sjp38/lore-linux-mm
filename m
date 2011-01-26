Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 7612D6B0092
	for <linux-mm@kvack.org>; Tue, 25 Jan 2011 20:38:54 -0500 (EST)
Date: Tue, 25 Jan 2011 20:38:50 -0500 (EST)
From: CAI Qian <caiqian@redhat.com>
Message-ID: <1570419329.157209.1296005930142.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
In-Reply-To: <645973813.157189.1296005440082.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
Subject: [LSF/MM TOPIC] sustainable upstream testing
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: lsf-pc@lists.linuxfoundation.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The benefit:
By regularly testing kernel upstream, we can identify problems and get the feeling of the status of enterprise user cases earlier before the bad code found a way into enterprise-distro kernel. We can also use this opportunity to drive a testing community around the kernel upstream which will even benefit enterprise-distro kernel further by gathering more testing knowledge, tools/testing code around features/subsystems, and establishing working relationships with upstream developers.

The challenge:
Upstream code have many different code bases (git trees) and release cycles. Internal automation system may not support easy installation/integration of upstream kernel yet. It could be time-consuming to clone those external upstream git trees. There is no guarantee that upstream developers will fix/debug bug/regression or help you to understand requirements for features. The requirement and usage documents for upstream code is more developer-bias and rely on code reading/work-through to understand. Those exposed new challenges for testers both technically and socially.

Main differences between upstream and enterprise-distro kernel testing:
1) more chances to find regression upstream.
2) more debugging, technical and communication skills required to get closures for the issues found.
3) no fixable release cycles.
4) different testing infrastructures upstream; hard to push/use internal tests upstream.
5) some enterprise use-cases/features may not well-accepted upstream.

Some sample questions to discuss:
1) how to choose the right git tree as a base to test?
2) how to efficiently/sustainably push more internal tests upstream?
3) how to get more tests passed as a part of release criteria? 
4) how to efficiently get the issues found upstream fixed?

Thanks.

CAI Qian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
