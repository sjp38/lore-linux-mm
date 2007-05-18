Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by ausmtp04.au.ibm.com (8.13.8/8.13.8) with ESMTP id l4I4RarB210084
	for <linux-mm@kvack.org>; Fri, 18 May 2007 14:27:36 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.250.244])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l4I4AxM3163372
	for <linux-mm@kvack.org>; Fri, 18 May 2007 14:11:00 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l4I47R0L027587
	for <linux-mm@kvack.org>; Fri, 18 May 2007 14:07:28 +1000
Message-ID: <464D267A.50107@linux.vnet.ibm.com>
Date: Fri, 18 May 2007 09:37:22 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: RSS controller v2 Test results (lmbench )
References: <464C95D4.7070806@linux.vnet.ibm.com> <464D1599.1000506@redhat.com>
In-Reply-To: <464D1599.1000506@redhat.com>
Content-Type: multipart/mixed;
 boundary="------------090506080404050703080701"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Pavel Emelianov <xemul@sw.ru>, Paul Menage <menage@google.com>, Kirill Korotaev <dev@sw.ru>, devel@openvz.org, Linux Containers <containers@lists.osdl.org>, linux kernel mailing list <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, "Eric W. Biederman" <ebiederm@xmission.com>, Herbert Poetzl <herbert@13thfloor.at>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------090506080404050703080701
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit

Rik van Riel wrote:
> Balbir Singh wrote:
> 
>> A meaningful container size does not hamper performance. I am in the
>> process
>> of getting more results (with varying container sizes). Please let me
>> know
>> what you think of the results? Would you like to see different
>> benchmarks/
>> tests/configuration results?
> 
> AIM7 results might be interesting, especially when run to crossover.
> 

I'll try and get hold of AIM7, I have some AIM9 results (please
see the attachment, since the results overflow 80 columns, I've
attached them).

> OTOH, AIM7 can make the current VM explode spectacularly :)
> 
> I saw it swap out 1.4GB of memory in one run, on my 2GB memory test
> system.  That's right, it swapped out almost 75% of memory.
> 

This would make a good test case for the RSS and the unmapped page
cache controller. Thanks for bringing it to my attention.

> Presumably all the AIM7 processes got stuck in the pageout code
> simultaneously and all decided they needed to swap some pages out.
> However, the shell got stuck too so I could not get sysrq output
> on time.
> 

oops! I wonder if AIM7 creates too many processes and exhausts all
memory. I've seen a case where during an upgrade of my tetex on my
laptop, the setup process failed and continued to fork processes
filling up 4GB of swap.

> I am trying out a little VM patch to fix that now, carefully watching
> vmstat output.  Should be fun...
> 

VM debugging is always fun!

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--------------090506080404050703080701
Content-Type: text/plain;
 name="aim9"
Content-Transfer-Encoding: base64
Content-Disposition: inline;
 filename="aim9"

LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
CiBUZXN0ICAgICAgICBUZXN0ICAgICAgICBFbGFwc2VkICBJdGVyYXRpb24gICAgSXRlcmF0
aW9uICAgICAgICAgIE9wZXJhdGlvbgpOdW1iZXIgICAgICAgTmFtZSAgICAgIFRpbWUgKHNl
YykgICBDb3VudCAgIFJhdGUgKGxvb3BzL3NlYykgICAgUmF0ZSAob3BzL3NlYykKLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tCiAgICAg
MSBjcmVhdC1jbG8gICAgICAgICAgIDYwLjAwICAgICAgIDg4ODUgIDE0OC4wODMzMyAgICAg
ICAxNDgwODMuMzMgRmlsZSBDcmVhdGlvbnMgYW5kIENsb3Nlcy9zZWNvbmQgICgyNTYgTUIg
Y29udGFpbmVyKQogICAgIDEgY3JlYXQtY2xvICAgICAgICAgICA2MC4wMSAgICAgICA4NTQ3
ICAxNDIuNDI2MjYgICAgICAgMTQyNDI2LjI2IEZpbGUgQ3JlYXRpb25zIGFuZCBDbG9zZXMv
c2Vjb25kICAodW5saW1pdGVkIGNvbnRhaW5lcikKICAgICAxIGNyZWF0LWNsbyAgICAgICAg
ICAgNjAuMDEgICAgICAgODYzMiAgMTQzLjg0MjY5ICAgICAgIDE0Mzg0Mi42OSBGaWxlIENy
ZWF0aW9ucyBhbmQgQ2xvc2VzL3NlY29uZCAgKGNvbnRhaW5lciBub3QgbW91bnRlZCkKICAg
ICAyIHBhZ2VfdGVzdCAgICAgICAgICAgNjAuMDAgICAgICAgNjA2OCAgMTAxLjEzMzMzICAg
ICAgIDE3MTkyNi42NyBTeXN0ZW0gQWxsb2NhdGlvbnMgJiBQYWdlcy9zZWNvbmQgKDI1NiBN
QiBjb250YWluZXIpCiAgICAgMiBwYWdlX3Rlc3QgICAgICAgICAgIDYwLjAwICAgICAgIDUy
NzUgICA4Ny45MTY2NyAgICAgICAxNDk0NTguMzMgU3lzdGVtIEFsbG9jYXRpb25zICYgUGFn
ZXMvc2Vjb25kICAodW5saW1pdGVkIGNvbnRhaW5lcikKICAgICAyIHBhZ2VfdGVzdCAgICAg
ICAgICAgNjAuMDEgICAgICAgNTQxMSAgIDkwLjE2ODMxICAgICAgIDE1MzI4Ni4xMiBTeXN0
ZW0gQWxsb2NhdGlvbnMgJiBQYWdlcy9zZWNvbmQgIChjb250YWluZXIgbm90IG1vdW50ZWQp
CiAgICAgMyBicmtfdGVzdCAgICAgICAgICAgIDYwLjAxICAgICAgIDkxNTEgIDE1Mi40OTEy
NSAgICAgIDI1OTIzNTEuMjcgU3lzdGVtIE1lbW9yeSBBbGxvY2F0aW9ucy9zZWNvbmQgICgy
NTYgTUIgY29udGFpbmVyKQogICAgIDMgYnJrX3Rlc3QgICAgICAgICAgICA2MC4wMiAgICAg
ICA3NDA0ICAxMjMuMzU4ODggICAgICAyMDk3MTAwLjk3IFN5c3RlbSBNZW1vcnkgQWxsb2Nh
dGlvbnMvc2Vjb25kICAodW5saW1pdGVkIGNvbnRhaW5lcikKICAgICAzIGJya190ZXN0ICAg
ICAgICAgICAgNjAuMDEgICAgICAgODI5NCAgMTM4LjIxMDMwICAgICAgMjM0OTU3NS4wNyBT
eXN0ZW0gTWVtb3J5IEFsbG9jYXRpb25zL3NlY29uZCAgKGNvbnRhaW5lciBub3QgbW91bnRl
ZCkKICAgICA0IGptcF90ZXN0ICAgICAgICAgICAgNjAuMDEgICAgIDk4MzA2MiAxNjM4MS42
MzYzOSAgICAgMTYzODE2MzYuMzkgTm9uLWxvY2FsIGdvdG9zL3NlY29uZCAgKDI1NiBNQiBj
b250YWluZXIpCiAgICAgNCBqbXBfdGVzdCAgICAgICAgICAgIDYwLjAwICAgICA5ODMwODQg
MTYzODQuNzMzMzMgICAgIDE2Mzg0NzMzLjMzIE5vbi1sb2NhbCBnb3Rvcy9zZWNvbmQgICh1
bmxpbWl0ZWQgY29udGFpbmVyKQogICAgIDQgam1wX3Rlc3QgICAgICAgICAgICA2MC4wMCAg
ICAgOTgyOTA0IDE2MzgxLjczMzMzICAgICAxNjM4MTczMy4zMyBOb24tbG9jYWwgZ290b3Mv
c2Vjb25kICAoY29udGFpbmVyIG5vdCBtb3VudGVkKQogICAgIDUgc2lnbmFsX3Rlc3QgICAg
ICAgICA2MC4wMSAgICAgIDI4MDEzICA0NjYuODA1NTMgICAgICAgNDY2ODA1LjUzIFNpZ25h
bCBUcmFwcy9zZWNvbmQgICgyNTYgTUIgY29udGFpbmVyKQogICAgIDUgc2lnbmFsX3Rlc3Qg
ICAgICAgICA2MC4wMCAgICAgIDI4MzYwICA0NzIuNjY2NjcgICAgICAgNDcyNjY2LjY3IFNp
Z25hbCBUcmFwcy9zZWNvbmQgICh1bmxpbWl0ZWQgY29udGFpbmVyKQogICAgIDUgc2lnbmFs
X3Rlc3QgICAgICAgICA2MC4wMSAgICAgIDI4NTkzICA0NzYuNDcwNTkgICAgICAgNDc2NDcw
LjU5IFNpZ25hbCBUcmFwcy9zZWNvbmQgIChjb250YWluZXIgbm90IG1vdW50ZWQpCiAgICAg
NiBleGVjX3Rlc3QgICAgICAgICAgIDYwLjAyICAgICAgIDI1OTYgICA0My4yNTIyNSAgICAg
ICAgICAyMTYuMjYgUHJvZ3JhbSBMb2Fkcy9zZWNvbmQgICgyNTYgTUIgY29udGFpbmVyKQog
ICAgIDYgZXhlY190ZXN0ICAgICAgICAgICA2MC4wMiAgICAgICAyNTM5ICAgNDIuMzAyNTcg
ICAgICAgICAgMjExLjUxIFByb2dyYW0gTG9hZHMvc2Vjb25kICAodW5saW1pdGVkIGNvbnRh
aW5lcikKICAgICA2IGV4ZWNfdGVzdCAgICAgICAgICAgNjAuMDEgICAgICAgMjUzNiAgIDQy
LjI1OTYyICAgICAgICAgIDIxMS4zMCBQcm9ncmFtIExvYWRzL3NlY29uZCAgKGNvbnRhaW5l
ciBub3QgbW91bnRlZCkKICAgICA3IGZvcmtfdGVzdCAgICAgICAgICAgNjAuMDEgICAgICAg
MjExOCAgIDM1LjI5NDEyICAgICAgICAgMzUyOS40MSBUYXNrIENyZWF0aW9ucy9zZWNvbmQg
ICgyNTYgTUIgY29udGFpbmVyKQogICAgIDcgZm9ya190ZXN0ICAgICAgICAgICA2MC4wMyAg
ICAgICAyMTMwICAgMzUuNDgyMjYgICAgICAgICAzNTQ4LjIzIFRhc2sgQ3JlYXRpb25zL3Nl
Y29uZCAgKHVubGltaXRlZCBjb250YWluZXIpCiAgICAgNyBmb3JrX3Rlc3QgICAgICAgICAg
IDYwLjAxICAgICAgIDIxMzAgICAzNS40OTQwOCAgICAgICAgIDM1NDkuNDEgVGFzayBDcmVh
dGlvbnMvc2Vjb25kICAoY29udGFpbmVyIG5vdCBtb3VudGVkKQogICAgIDggbGlua190ZXN0
ICAgICAgICAgICA2MC4wMiAgICAgIDQ3NzYwICA3OTUuNzM0NzYgICAgICAgIDUwMTMxLjI5
IExpbmsvVW5saW5rIFBhaXJzL3NlY29uZCAgKDI1NiBNQiBjb250YWluZXIpCiAgICAgOCBs
aW5rX3Rlc3QgICAgICAgICAgIDYwLjAyICAgICAgNDgxNTYgIDgwMi4zMzI1NiAgICAgICAg
NTA1NDYuOTUgTGluay9VbmxpbmsgUGFpcnMvc2Vjb25kICAodW5saW1pdGVkIGNvbnRhaW5l
cikKICAgICA4IGxpbmtfdGVzdCAgICAgICAgICAgNjAuMDAgICAgICA0OTc3OCAgODI5LjYz
MzMzICAgICAgICA1MjI2Ni45MCBMaW5rL1VubGluayBQYWlycy9zZWNvbmQgIChjb250YWlu
ZXIgbm90IG1vdW50ZWQpCi0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLQo=
--------------090506080404050703080701--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
