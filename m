Message-ID: <017B1BB60535DF4285666089FA048AC2A2E45B@SONOMA.netscreen.com>
From: Mike Ji <hji@netscreen.com>
Subject: Thoughts about RTCore and RTLinux
Date: Thu, 4 Mar 2004 08:48:10 -0800 
MIME-Version: 1.0
List-Help: kernelnewbies
List-Subscribe: <mailto:kernelnewbies-request@nl.linux.org?Subject=subscribe>
List-Unsubscribe: <mailto:kernelnewbies-request@nl.linux.org?Subject=unsubscribe>
Content-Type: text/plain;
	charset="iso-8859-1"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi, folks,

I happen to read some white papers related to RTLinux. Below is some of
my personal thoughts/questions. 

* RTLinux's so called realtime extension-RTCORE  **was* to address the
previous issue--Linux is not realtime supported, for example, fully
kernel-preemptive; posix realtime extension. 

* After linux 2.6, I did not see any outstanding reason that people
still need to use a RTLinux **patch** to achieve realtime applications.
I mean, why not just linux itself? Not needed RTCORE anymore.

* From os/kernel viewpoint, it is very hard for me to position RTCORE,
but a realtime patch. I mean, RTCORE is not able to be identified into any
well-known os architecture. 

* If there is a very high performance micro-kernel, say, L4 or
QNX/Neutrino, I personally think it is much better than the RTCORE stuff,
which HAVE TO bind a secondary os as running time environment.

Some personal thoughts,
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
