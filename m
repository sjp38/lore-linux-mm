Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3FB32280278
	for <linux-mm@kvack.org>; Fri,  4 Nov 2016 04:24:42 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id a136so18590444pfa.5
        for <linux-mm@kvack.org>; Fri, 04 Nov 2016 01:24:42 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id xs9si12567032pab.86.2016.11.04.01.24.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Nov 2016 01:24:41 -0700 (PDT)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uA48NT3w113756
	for <linux-mm@kvack.org>; Fri, 4 Nov 2016 04:24:40 -0400
Received: from e23smtp07.au.ibm.com (e23smtp07.au.ibm.com [202.81.31.140])
	by mx0a-001b2d01.pphosted.com with ESMTP id 26gexfd6rp-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 04 Nov 2016 04:24:40 -0400
Received: from localhost
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dingzhh@cn.ibm.com>;
	Fri, 4 Nov 2016 18:24:38 +1000
Received: from d23relay07.au.ibm.com (d23relay07.au.ibm.com [9.190.26.37])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 42F8D2BB0045
	for <linux-mm@kvack.org>; Fri,  4 Nov 2016 19:24:35 +1100 (EST)
Received: from d23av06.au.ibm.com (d23av06.au.ibm.com [9.190.235.151])
	by d23relay07.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id uA48OZjW17760382
	for <linux-mm@kvack.org>; Fri, 4 Nov 2016 19:24:35 +1100
Received: from d23av06.au.ibm.com (localhost [127.0.0.1])
	by d23av06.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id uA48OZZe002222
	for <linux-mm@kvack.org>; Fri, 4 Nov 2016 19:24:35 +1100
Received: from d50lp01.ny.us.ibm.com (d50lp01.pok.ibm.com [146.89.104.207])
	by d23av06.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVin) with ESMTP id uA48OWJK002096
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-mm@kvack.org>; Fri, 4 Nov 2016 19:24:34 +1100
Received: from localhost
	by d50lp01.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dingzhh@cn.ibm.com>;
	Fri, 4 Nov 2016 04:24:31 -0400
Received: from localhost
	by smtp.notes.na.collabserv.com with smtp.notes.na.collabserv.com ESMTP
	for <linux-mm@kvack.org> from <dingzhh@cn.ibm.com>;
	Fri, 4 Nov 2016 08:24:27 -0000
Subject: memory.force_empty is deprecated
From: "Zhao Hui Ding" <dingzhh@cn.ibm.com>
Date: Fri, 4 Nov 2016 16:24:25 +0800
MIME-Version: 1.0
Content-Type: multipart/alternative; boundary="=_alternative 002E2D8D48258061_="
Message-Id: <OF57AEC2D2.FA566D70-ON48258061.002C144F-48258061.002E2E50@notes.na.collabserv.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org


--=_alternative 002E2D8D48258061_=
Content-Transfer-Encoding: base64
Content-Type: text/plain; charset="GB2312"

SGVsbG8sDQoNCkknbSBaaGFvaHVpIGZyb20gSUJNIFNwZWN0cnVtIExTRiBkZXZlbG9wbWVudCB0
ZWFtLiBJIGdvdCBiZWxvdyBtZXNzYWdlIA0Kd2hlbiBydW5uaW5nIExTRiBvbiBTVVNFMTEuNCwg
c28gSSB3b3VsZCBsaWtlIHRvIHNoYXJlIG91ciB1c2Ugc2NlbmFyaW8gDQphbmQgYXNrIGZvciB0
aGUgc3VnZ2VzdGlvbnMgd2l0aG91dCB1c2luZyBtZW1vcnkuZm9yY2VfZW1wdHkuDQoNCm1lbW9y
eS5mb3JjZV9lbXB0eSBpcyBkZXByZWNhdGVkIGFuZCB3aWxsIGJlIHJlbW92ZWQuIExldCB1cyBr
bm93IGlmIGl0IGlzIA0KbmVlZGVkIGluIHlvdXIgdXNlY2FzZSBhdCBsaW51eC1tbUBrdmFjay5v
cmcNCg0KTFNGIGlzIGEgYmF0Y2ggd29ya2xvYWQgc2NoZWR1bGVyLCBpdCB1c2VzIGNncm91cCB0
byBkbyBiYXRjaCBqb2JzIA0KcmVzb3VyY2UgZW5mb3JjZW1lbnQgYW5kIGFjY291bnRpbmcuIEZv
ciBlYWNoIGpvYiwgTFNGIGNyZWF0ZXMgYSBjZ3JvdXAgDQpkaXJlY3RvcnkgYW5kIHB1dCBqb2In
cyBQSURzIHRvIHRoZSBjZ3JvdXAuDQoNCldoZW4gd2UgaW1wbGVtZW50IExTRiBjZ3JvdXAgaW50
ZWdyYXRpb24sIHdlIGZvdW5kIGNyZWF0aW5nIGEgbmV3IGNncm91cCANCmlzIG11Y2ggc2xvd2Vy
IHRoYW4gcmVuYW1pbmcgYW4gZXhpc3RpbmcgY2dyb3VwLCBpdCdzIGFib3V0IGh1bmRyZWRzIG9m
IA0KbWlsbGlzZWNvbmRzIHZzIGxlc3MgdGhhbiAxMCBtaWxsaXNlY29uZHMuDQpUbyBzcGVlZCB1
cCBqb2IgY2xlYW4gdXAsIHdoZW4gYSBqb2IgaXMgZG9uZSwgTFNGIGRvZXNuJ3QgZGVsZXRlIHRo
ZSANCmNncm91cCwgaW5zdGVhZCwgTFNGIHJlc2V0IHRoZSBtZW1vcnkgdXNhZ2UgYnkgc2V0dGlu
ZyBtZW1vcnkuZm9yY2VfZW1wdHkgDQp0byAiMCIuIFRoZSBzdWJzZXF1ZW50IGpvYiB3aWxsIHJl
bmFtZSB0aGUgY2dyb3VwIG5hbWUgYW5kIHJldXNlIGl0Lg0KDQpJZiBtZW1vcnkuZm9yY2VfZW1w
dHkgd2lsbCBiZSByZW1vdmVkLCBob3cgdG8gYWNoaWV2ZSB0aGUgc2FtZSBnb2FsPw0KDQpMb29r
aW5nIGZvcndhcmQgZm9yIHlvdSByZXBseS4NCg0KVGhhbmtzICYgUmVnYXJkcywNCg0KWmhhb2h1
aSBEaW5nICi2odXYu9QpLCBQaC5EDQpTZW5pb3IgUHJvZHVjdCBBcmNoaXRlY3QsIElCTSBQbGF0
Zm9ybSBMU0YgUHJvZHVjdCBMaW5lDQpJQk0gQ2hpbmEgU3lzdGVtcyBhbmQgVGVjaG5vbG9neSBM
YWJvcmF0b3J5IGluIEJlaWppbmcNCkFkZHI6IEJ1aWxkaW5nIDI4LCBaaG9uZ0d1YW5DdW4gU29m
dHdhcmUgUGFyaywgTm8uOCBEb25nIEJlaSBXYW5nIFdlc3QgDQpSb2FkDQpPZmZpY2UgOiAoODYt
MTApIDgyNDUwOTAzICAgTW9iaWxlIDogKDg2KSAxODYtMTE5OC0yMTc5DQoNCg==

--=_alternative 002E2D8D48258061_=
Content-Transfer-Encoding: base64
Content-Type: text/html; charset="GB2312"

PGZvbnQgc2l6ZT0yIGZhY2U9InNhbnMtc2VyaWYiPkhlbGxvLDwvZm9udD48YnI+PGJyPjxmb250
IHNpemU9MiBmYWNlPSJzYW5zLXNlcmlmIj5JJ20gWmhhb2h1aSBmcm9tIElCTSBTcGVjdHJ1bSBM
U0YgZGV2ZWxvcG1lbnQNCnRlYW0uIEkgZ290IGJlbG93IG1lc3NhZ2Ugd2hlbiBydW5uaW5nIExT
RiBvbiBTVVNFMTEuNCwgc28gSSB3b3VsZCBsaWtlDQp0byBzaGFyZSBvdXIgdXNlIHNjZW5hcmlv
IGFuZCBhc2sgZm9yIHRoZSBzdWdnZXN0aW9ucyB3aXRob3V0IHVzaW5nIG1lbW9yeS5mb3JjZV9l
bXB0eS48L2ZvbnQ+PGJyPjxicj48Zm9udCBzaXplPTMgY29sb3I9IzAwNDA4MCBmYWNlPSJzYW5z
LXNlcmlmIj48aT5tZW1vcnkuZm9yY2VfZW1wdHkNCmlzIGRlcHJlY2F0ZWQgYW5kIHdpbGwgYmUg
cmVtb3ZlZC4gTGV0IHVzIGtub3cgaWYgaXQgaXMgbmVlZGVkIGluIHlvdXINCnVzZWNhc2UgYXQg
PC9pPjwvZm9udD48YSBocmVmPSJtYWlsdG86bGludXgtbW1Aa3ZhY2sub3JnIiB0YXJnZXQ9X2Js
YW5rPjxmb250IHNpemU9MyBjb2xvcj0jMDA4MmJmIGZhY2U9InNhbnMtc2VyaWYiPjxpPjx1Pmxp
bnV4LW1tQGt2YWNrLm9yZzwvdT48L2k+PC9mb250PjwvYT48YnI+PGJyPjxmb250IHNpemU9MiBm
YWNlPSJzYW5zLXNlcmlmIj5MU0YgaXMgYSBiYXRjaCB3b3JrbG9hZCBzY2hlZHVsZXIsIGl0DQp1
c2VzIGNncm91cCB0byBkbyBiYXRjaCBqb2JzIHJlc291cmNlIGVuZm9yY2VtZW50IGFuZCBhY2Nv
dW50aW5nLiBGb3IgZWFjaA0Kam9iLCBMU0YgY3JlYXRlcyBhIGNncm91cCBkaXJlY3RvcnkgYW5k
IHB1dCBqb2IncyBQSURzIHRvIHRoZSBjZ3JvdXAuPC9mb250Pjxicj48YnI+PGZvbnQgc2l6ZT0y
IGZhY2U9InNhbnMtc2VyaWYiPldoZW4gd2UgaW1wbGVtZW50IExTRiBjZ3JvdXAgaW50ZWdyYXRp
b24sDQp3ZSBmb3VuZCBjcmVhdGluZyBhIG5ldyBjZ3JvdXAgaXMgbXVjaCBzbG93ZXIgdGhhbiBy
ZW5hbWluZyBhbiBleGlzdGluZw0KY2dyb3VwLCBpdCdzIGFib3V0IGh1bmRyZWRzIG9mIG1pbGxp
c2Vjb25kcyB2cyBsZXNzIHRoYW4gMTAgbWlsbGlzZWNvbmRzLjwvZm9udD48YnI+PGZvbnQgc2l6
ZT0yIGZhY2U9InNhbnMtc2VyaWYiPlRvIHNwZWVkIHVwIGpvYiBjbGVhbiB1cCwgd2hlbiBhIGpv
Yg0KaXMgZG9uZSwgTFNGIGRvZXNuJ3QgZGVsZXRlIHRoZSBjZ3JvdXAsIGluc3RlYWQsIExTRiBy
ZXNldCB0aGUgbWVtb3J5IHVzYWdlDQpieSBzZXR0aW5nIG1lbW9yeS5mb3JjZV9lbXB0eSB0byAm
cXVvdDswJnF1b3Q7LiBUaGUgc3Vic2VxdWVudCBqb2Igd2lsbA0KcmVuYW1lIHRoZSBjZ3JvdXAg
bmFtZSBhbmQgcmV1c2UgaXQuPC9mb250Pjxicj48YnI+PGZvbnQgc2l6ZT0yIGZhY2U9InNhbnMt
c2VyaWYiPklmIG1lbW9yeS5mb3JjZV9lbXB0eSB3aWxsIGJlIHJlbW92ZWQsDQpob3cgdG8gYWNo
aWV2ZSB0aGUgc2FtZSBnb2FsPzwvZm9udD48YnI+PGJyPjxmb250IHNpemU9MiBmYWNlPSJzYW5z
LXNlcmlmIj5Mb29raW5nIGZvcndhcmQgZm9yIHlvdSByZXBseS48L2ZvbnQ+PGJyPjxicj48Zm9u
dCBzaXplPTIgZmFjZT0ic2Fucy1zZXJpZiI+VGhhbmtzICZhbXA7IFJlZ2FyZHMsPC9mb250Pjxi
cj48YnI+PGZvbnQgc2l6ZT0yIGZhY2U9InNhbnMtc2VyaWYiPlpoYW9odWkgRGluZyAotqHV2LvU
KSwgUGguRDxicj5TZW5pb3IgUHJvZHVjdCBBcmNoaXRlY3QsIElCTSBQbGF0Zm9ybSBMU0YgUHJv
ZHVjdCBMaW5lPGJyPklCTSBDaGluYSBTeXN0ZW1zIGFuZCBUZWNobm9sb2d5IExhYm9yYXRvcnkg
aW4gQmVpamluZzxicj5BZGRyOiBCdWlsZGluZyAyOCwgWmhvbmdHdWFuQ3VuIFNvZnR3YXJlIFBh
cmssIE5vLjggRG9uZyBCZWkgV2FuZyBXZXN0DQpSb2FkPGJyPk9mZmljZSA6ICg4Ni0xMCkgODI0
NTA5MDMgJm5ic3A7IE1vYmlsZSA6ICg4NikgMTg2LTExOTgtMjE3OTwvZm9udD48QlI+DQo=
--=_alternative 002E2D8D48258061_=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
