Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id DE9516B0002
	for <linux-mm@kvack.org>; Tue, 21 May 2013 03:02:46 -0400 (EDT)
Message-ID: <519B1C45.5090201@parallels.com>
Date: Tue, 21 May 2013 11:03:33 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v7 00/34] kmemcg shrinkers
References: <1368994047-5997-1-git-send-email-glommer@openvz.org>
In-Reply-To: <1368994047-5997-1-git-send-email-glommer@openvz.org>
Content-Type: multipart/mixed;
	boundary="------------060309020000020106080006"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@openvz.org>, Dave Chinner <david@fromorbit.com>, Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel@vger.kernel.org, hughd@google.com

--------------060309020000020106080006
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit

On 05/20/2013 12:06 AM, Glauber Costa wrote:
> Initial notes:
> ==============
> 
> Please pay attention to new patches that are debuting in this series. Patch1
> changes our unused countries for int to long, since Dave noticed that it wasn't
> being enough in some cases. Aside from that, the major change is that we now
> compute and keep deferred work per-node (Patch13). The biggest effect of this,
> is that to avoid storing a new nodemask in the stack, I am passing only the
> node id down to the API. This means that the lru API *does not* take a nodemask
> any longer, which in turn, makes it simpler.
> 
> I deeply considered this matter, and decided this would be the best way to go.
> It is not different from what I have already done for memcgs: Only a single one
> is passed down, and the complexity of scanning them is moved upwards to the
> caller, where all the scanning logic should belong anyway.
> 
> If you want, you can also grab from branch "kmemcg-lru-shrinker" at:
> 
> 	git://git.kernel.org/pub/scm/linux/kernel/git/glommer/memcg.git
> 
> I hope the performance problems are all gone. My testing now shows a smoother
> and steady state for the objects during the lifetime of the workload, and
> postmark numbers are closer to base, although we do deviate a bit.
> 

Mel, Dave, et. al.

I have applied some more fixes for things I have found here and there as
a result of a new round of testing. I won't post the result here until
Thursday or Friday, to avoid patchbombing you guys. In the meantime I
will be merging comments I receive from this version.

My git tree is up to date, so if you want to test it further, please
pick that up.

I am attaching the result of my postmark run. I think the results look
really good now.



--------------060309020000020106080006
Content-Type: text/plain; charset="UTF-8"; name="postmark"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="postmark"

CnBvc3RtYXJrCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgYmFz
ICAgICAgICAgICAgICAgICBtZW1jZwogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgYmFzZSAgICAgICAgICAgICAgICAgZmluYWwKT3BzL3NlYyBUcmFuc2FjdGlv
bnMgICAgICAgICAxMy4wMCAoICAwLjAwJSkgICAgICAgMTIuMDAgKCAtNy42OSUpCk9wcy9z
ZWMgRmlsZXNDcmVhdGUgICAgICAgICAgMjUuMDAgKCAgMC4wMCUpICAgICAgIDI2LjAwICgg
IDQuMDAlKQpPcHMvc2VjIENyZWF0ZVRyYW5zYWN0ICAgICAgICA2LjAwICggIDAuMDAlKSAg
ICAgICAgNi4wMCAoICAwLjAwJSkKT3BzL3NlYyBGaWxlc0RlbGV0ZWQgICAgICAgMzkzNS4w
MCAoICAwLjAwJSkgICAgIDMzNzMuMDAgKC0xNC4yOCUpCk9wcy9zZWMgRGVsZXRlVHJhbnNh
Y3QgICAgICAgIDYuMDAgKCAgMC4wMCUpICAgICAgICA2LjAwICggIDAuMDAlKQpPcHMvc2Vj
IERhdGFSZWFkL01CICAgICAgICAgICA2LjU4ICggIDAuMDAlKSAgICAgICAgNi42MyAoICAw
Ljc2JSkKT3BzL3NlYyBEYXRhV3JpdGUvTUIgICAgICAgICA0OC42MyAoICAwLjAwJSkgICAg
ICAgNDguOTkgKCAgMC43NCUpCgogICAgICAgICAgICAgICAgIGJhcyAgICAgICBtZW1jZwog
ICAgICAgICAgICAgICAgYmFzZSAgICAgICBmaW5hbApVc2VyICAgICAgICAgICA0NC4zMyAg
ICAgICA0My41OApTeXN0ZW0gICAgICAgIDQ0Ny44NiAgICAgIDQ4OC40NgpFbGFwc2VkICAg
ICAgMzAwMC44MiAgICAgMjk3Ny44NgoKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICBiYXMgICAgICAgbWVtY2cKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
IGJhc2UgICAgICAgZmluYWwKUGFnZSBJbnMgICAgICAgICAgICAgICAgICAgICAgMTA4MTA0
MDAgICAgMTA4NDM2MDQKUGFnZSBPdXRzICAgICAgICAgICAgICAgICAgICAxNTE0ODY2MzIg
ICAxNTA2NDA4ODQKU3dhcCBJbnMgICAgICAgICAgICAgICAgICAgICAgICAgICAgIDAgICAg
ICAgICAgIDAKU3dhcCBPdXRzICAgICAgICAgICAgICAgICAgICAgICAgICAgIDAgICAgICAg
ICAgIDAKRGlyZWN0IHBhZ2VzIHNjYW5uZWQgICAgICAgICAgICAgICAgIDAgICAgICAgICAg
IDAKS3N3YXBkIHBhZ2VzIHNjYW5uZWQgICAgICAgICAgMjM0MTA3MjIgICAgMjM0NTgyMzIK
S3N3YXBkIHBhZ2VzIHJlY2xhaW1lZCAgICAgICAgMjMzOTk4NjggICAgMjM0NDcyNzYKRGly
ZWN0IHBhZ2VzIHJlY2xhaW1lZCAgICAgICAgICAgICAgIDAgICAgICAgICAgIDAKS3N3YXBk
IGVmZmljaWVuY3kgICAgICAgICAgICAgICAgICA5OSUgICAgICAgICA5OSUKS3N3YXBkIHZl
bG9jaXR5ICAgICAgICAgICAgICAgNzgwMS40NDIgICAgNzg3Ny41NDcKRGlyZWN0IGVmZmlj
aWVuY3kgICAgICAgICAgICAgICAgIDEwMCUgICAgICAgIDEwMCUKRGlyZWN0IHZlbG9jaXR5
ICAgICAgICAgICAgICAgICAgMC4wMDAgICAgICAgMC4wMDAKUGVyY2VudGFnZSBkaXJlY3Qg
c2NhbnMgICAgICAgICAgICAgMCUgICAgICAgICAgMCUKUGFnZSB3cml0ZXMgYnkgcmVjbGFp
bSAgICAgICAgICAgICAgIDAgICAgICAgICAgIDAKUGFnZSB3cml0ZXMgZmlsZSAgICAgICAg
ICAgICAgICAgICAgIDAgICAgICAgICAgIDAKUGFnZSB3cml0ZXMgYW5vbiAgICAgICAgICAg
ICAgICAgICAgIDAgICAgICAgICAgIDAKUGFnZSByZWNsYWltIGltbWVkaWF0ZSAgICAgICAg
ICAgICAgIDAgICAgICAgICAgIDAKUGFnZSByZXNjdWVkIGltbWVkaWF0ZSAgICAgICAgICAg
ICAgIDAgICAgICAgICAgIDAKU2xhYnMgc2Nhbm5lZCAgICAgICAgICAgICAgICAgICAxOTQz
MDQgICAgICAyMzQzNjgKRGlyZWN0IGlub2RlIHN0ZWFscyAgICAgICAgICAgICAgICAgIDAg
ICAgICAgICAgIDAKS3N3YXBkIGlub2RlIHN0ZWFscyAgICAgICAgICAgICAgMjc0MTIgICAg
ICAgIDI2MDAKS3N3YXBkIHNraXBwZWQgd2FpdCAgICAgICAgICAgICAgICAgIDAgICAgICAg
ICAgIDAKVEhQIGZhdWx0IGFsbG9jICAgICAgICAgICAgICAgICAgICAgIDYgICAgICAgICAg
IDYKVEhQIGNvbGxhcHNlIGFsbG9jICAgICAgICAgICAgICAgICAgNDMgICAgICAgICAgMzkK
VEhQIHNwbGl0cyAgICAgICAgICAgICAgICAgICAgICAgICAgIDEgICAgICAgICAgIDEKVEhQ
IGZhdWx0IGZhbGxiYWNrICAgICAgICAgICAgICAgICAgIDAgICAgICAgICAgIDAKVEhQIGNv
bGxhcHNlIGZhaWwgICAgICAgICAgICAgICAgICAgIDAgICAgICAgICAgIDAKQ29tcGFjdGlv
biBzdGFsbHMgICAgICAgICAgICAgICAgICAgIDAgICAgICAgICAgIDAKQ29tcGFjdGlvbiBz
dWNjZXNzICAgICAgICAgICAgICAgICAgIDAgICAgICAgICAgIDAKQ29tcGFjdGlvbiBmYWls
dXJlcyAgICAgICAgICAgICAgICAgIDAgICAgICAgICAgIDAKUGFnZSBtaWdyYXRlIHN1Y2Nl
c3MgICAgICAgICAgICAgICAgIDAgICAgICAgICAgIDAKUGFnZSBtaWdyYXRlIGZhaWx1cmUg
ICAgICAgICAgICAgICAgIDAgICAgICAgICAgIDAKQ29tcGFjdGlvbiBwYWdlcyBpc29sYXRl
ZCAgICAgICAgICAgIDAgICAgICAgICAgIDAKQ29tcGFjdGlvbiBtaWdyYXRlIHNjYW5uZWQg
ICAgICAgICAgIDAgICAgICAgICAgIDAKQ29tcGFjdGlvbiBmcmVlIHNjYW5uZWQgICAgICAg
ICAgICAgIDAgICAgICAgICAgIDAKQ29tcGFjdGlvbiBjb3N0ICAgICAgICAgICAgICAgICAg
ICAgIDAgICAgICAgICAgIDAKTlVNQSBQVEUgdXBkYXRlcyAgICAgICAgICAgICAgICAgICAg
IDAgICAgICAgICAgIDAKTlVNQSBoaW50IGZhdWx0cyAgICAgICAgICAgICAgICAgICAgIDAg
ICAgICAgICAgIDAKTlVNQSBoaW50IGxvY2FsIGZhdWx0cyAgICAgICAgICAgICAgIDAgICAg
ICAgICAgIDAKTlVNQSBwYWdlcyBtaWdyYXRlZCAgICAgICAgICAgICAgICAgIDAgICAgICAg
ICAgIDAKQXV0b05VTUEgY29zdCAgICAgICAgICAgICAgICAgICAgICAgIDAgICAgICAgICAg
IDAK
--------------060309020000020106080006--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
