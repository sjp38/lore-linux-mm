Return-Path: <SRS0=2Zku=W5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: *
X-Spam-Status: No, score=1.1 required=3.0 tests=CHARSET_FARAWAY_HEADER,
	FROM_EXCESS_BASE64,HEADER_FROM_DIFFERENT_DOMAINS,HTML_MESSAGE,
	MAILING_LIST_MULTI,MIME_HTML_ONLY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BD42FC3A59B
	for <linux-mm@archiver.kernel.org>; Mon,  2 Sep 2019 04:35:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4F0EC206BA
	for <linux-mm@archiver.kernel.org>; Mon,  2 Sep 2019 04:35:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4F0EC206BA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lge.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A45F96B0003; Mon,  2 Sep 2019 00:35:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9F6EB6B0006; Mon,  2 Sep 2019 00:35:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8E77B6B0007; Mon,  2 Sep 2019 00:35:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0049.hostedemail.com [216.40.44.49])
	by kanga.kvack.org (Postfix) with ESMTP id 689766B0003
	for <linux-mm@kvack.org>; Mon,  2 Sep 2019 00:35:00 -0400 (EDT)
Received: from smtpin09.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id E7EB77593
	for <linux-mm@kvack.org>; Mon,  2 Sep 2019 04:34:59 +0000 (UTC)
X-FDA: 75888715518.09.jar82_82c5d69fe0a1f
X-HE-Tag: jar82_82c5d69fe0a1f
X-Filterd-Recvd-Size: 10516
Received: from lgeamrelo11.lge.com (lgeamrelo13.lge.com [156.147.23.53])
	by imf27.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  2 Sep 2019 04:34:58 +0000 (UTC)
Received: from unknown (HELO lgemrelse6q.lge.com) (156.147.1.121)
	by 156.147.23.53 with ESMTP; 2 Sep 2019 13:34:55 +0900
X-Original-SENDERIP: 156.147.1.121
X-Original-MAILFROM: sangwoo2.park@lge.com
Received: from unknown (HELO lgekrhqms39b.lge.com) (10.185.110.133)
	by 156.147.1.121 with ESMTP; 2 Sep 2019 13:34:55 +0900
X-Original-SENDERIP: 10.185.110.133
X-Original-MAILFROM: sangwoo2.park@lge.com
X-AuditID: 9c930172-f79446d00000751c-fd-5d6903d7d0b3
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Subject: RE: Re: [PATCH] mm: Add nr_free_highatomimic to fix incorrect watermatk
 routine
References: <1567157153-22024-1-git-send-email-sangwoo2.park@lge.com> 	<20190830110907.GC28313@dhcp22.suse.cz>
In-Reply-To: <20190830110907.GC28313@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Brightmail-Tracker: H4sIAAAAAAAAA1WSa0wTWRTHuTNDuSUduUzBHluMpuqGxbW+lQ8b1CjqxpKou7hGrTIrQ1tt
	C2krAl+WxCdECupKFIsiot2CrovxgY+wm6qoRKIhVcEHQYIEH0QJGEu2lJ2BoPjt5Px///+5
	5+RimquTqbGQ4xTsNt6ilUUyt/a9iJrRSpsNs66XT068e/aVbDFaWdjjp1ajDZE/pgsWc7Zg
	n5mUFmm6W/chPOsdzrnzrJLJR6ciCpEcA5kH/TWXqJF6PDxquyArRJGYI4coeN5+BY0Ic6Dn
	YIgaEY4gCB3zDDsYMg3+eVYtJmEsI9/Bqwad1I4hU8BVVTocRJOnNHjb24aDlGQdNBd1MhLP
	krnQE8yWSo4kw8snKySCJdFw/5hEyEVrArSE3lASQhMNeEJYasvJcujeFQyX2rFkKvRVkBIU
	XTbGXDbGXPbVXIHoaqTUr0hekrI2Wf/TrHk6i1HQbc20XkTiHd2Hkb0OdXtSfYhgpFWwiVeN
	Bi6cz3bkWn1oAqa0sezMjyYDN+63zPRcE+8wbbHvsAgOHwJMa2PYEytFjU3nc/MEe+aopMGM
	VsX+7Us3cMTIO4XtgpAl2EdVCkf4UBzGWmCnUGYDF20XjEJOhtniHMvIpQkKccI7iWEdWbzV
	YTaO6I1oBn69f28VzTG2TJugVrFpEkQkyLTD9iVn9KM0o4lqJYvCwsI4hfgQq9n5rf4W1SNx
	eSW7CokxCrPN+WXUnCpRITdkcKBoE3S7KhD0FldQEHB3MhD4dwhDR8kdOQz1+lm4994VBZ8q
	/4yC0O0eJYTO1qshuKdDA67dAxqov1UeBzWdnjiofXAzHlqCxdMh4D34Axw9dVUHx4cuLIFg
	642l0HK0ehkE+waTIdA1qIeCc9UpcMI98At0FLlT4WGT91co6Dq+HgLd1zfCX80tG+HT5SOb
	34rHosRj6U4L0rGc/NcN1PnIeW3SgtaEWD7GmzXQlJZbrq/tKr1yxuosif+jT3963c7SgDul
	v2a96+S2rUJ/g2JS9M/76aSytrTHHcV7f0/1/5dBnWnMu/iAaShtXKpZODdjfoFnocp/+1rO
	+XbjuMs3Pyd6U3caa/XLvl9T4D5pafzc2RTrn7zItZxL2PWxRLVApWUcJn52Am138P8DvEMn
	BcsDAAA=
MIME-Version: 1.0
Reply-To: "=?EUC-KR?B?udq787/s?=" <sangwoo2.park@lge.com>
X-Priority: 3 (Normal)
Auto-Submitted: auto-generated
From: "=?EUC-KR?B?udq787/s?=" <sangwoo2.park@lge.com>
To: Michal Hocko <mhocko@kernel.org>
Cc: hannes@cmpxchg.org,
	arunks@codeaurora.org,
	guro@fb.com,
	richard.weiyang@gmail.com,
	glider@google.com,
	jannh@google.com,
	dan.j.williams@intel.com,
	akpm@linux-foundation.org,
	alexander.h.duyck@linux.intel.com,
	rppt@linux.vnet.ibm.com,
	gregkh@linuxfoundation.org,
	janne.huttunen@nokia.com,
	pasha.tatashin@soleen.com,
	vbabka@suse.cz,
	osalvador@suse.de,
	mgorman@techsingularity.net,
	khlebnikov@yandex-team.ru,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Message-ID: <OF7501D4D5.8C005EEB-ON49258469.00192B40-49258469.00192B40@lge.com>
Date: Mon, 2 Sep 2019 13:34:54 +0900
X-MIMETrack: Itemize by http on LGEKRHQMS39B/LGE/LG Group(Release 9.0.1FP7HF850 | February
 23, 2018) at 2019/09/02 13:34:54,
	Serialize by Router on LGEKRHQMS39B/LGE/LG Group(Release 9.0.1FP7HF850 | February
 23, 2018) at 2019/09/02 13:34:54,
	Serialize complete at 2019/09/02 13:34:54
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Content-Type: text/html;
	charset="utf-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

PCFkb2N0eXBlIGh0bWw+PGh0bWw+PGhlYWQ+PHN0eWxlPnAge21hcmdpbjowO3BhZGRpbmc6MDt9
IGJvZHksIHRkLCBidXR0b24sIHAgeyBjb2xvcjojMDAwMDAwOyBmb250LXNpemU6MTBwdDsgZm9u
dC1mYW1pbHk6J01hbGd1biBHb3RoaWMnLCfrp5HsnYAg6rOg65SVJzsgbGluZS1oZWlnaHQ6bm9y
bWFsOyB9IGEsIGE6aG92ZXIsIGE6bGluaywgYTphY3RpdmUsIGE6dmlzaXRlZCB7IGNvbG9yOiMw
MDAwMDA7IH08L3N0eWxlPjwvaGVhZD48Ym9keSBzdHlsZT0iY29sb3I6IzAwMDAwMDsgZm9udC1z
aXplOjEwcHQ7IGZvbnQtZmFtaWx5OidNYWxndW4gR290aGljJywn66eR7J2AIOqzoOuUlSc7IGxp
bmUtaGVpZ2h0Om5vcm1hbDsiPjxwPiZndDtPbiBGcmkgMzAtMDgtMTkgMTg6MjU6NTMsIFNhbmd3
b28gd3JvdGU6PGJyPiZndDsmZ3Q7IFRoZSBoaWdoYXRvbWljIG1pZ3JhdGUgYmxvY2sgY2FuIGJl
IGluY3JlYXNlZCB0byAxJSBvZiBUb3RhbCBtZW1vcnkuPGJyPiZndDsmZ3Q7IEFuZCwgdGhpcyBp
cyBmb3Igb25seSBoaWdob3JkZXIgKCAmZ3Q7IDAgb3JkZXIpLiBTbywgdGhpcyBibG9jayBzaXpl
IGlzPGJyPiZndDsmZ3Q7IGV4Y2VwdGVkIGR1cmluZyBjaGVjayB3YXRlcm1hcmsgaWYgYWxsb2Nh
dGlvbiB0eXBlIGlzbid0IGFsbG9jX2hhcmRlci48YnI+Jmd0OyZndDsgPGJyPiZndDsmZ3Q7IEl0
IGhhcyBwcm9ibGVtLiBUaGUgdXNhZ2Ugb2YgaGlnaGF0b21pYyBpcyBhbHJlYWR5IGNhbGN1bGF0
ZWQgYXQgTlJfRlJFRV9QQUdFUy48YnI+Jmd0OyZndDsgU28sIGlmIHdlIGV4Y2VwdCB0b3RhbCBi
bG9jayBzaXplIG9mIGhpZ2hhdG9taWMsIGl0J3MgdHdpY2UgbWludXMgc2l6ZSBvZiBhbGxvY2F0
ZWQ8YnI+Jmd0OyZndDsgaGlnaGF0b21pYy48YnI+Jmd0OyZndDsgSXQncyBjYXVzZSBhbGxvY2F0
aW9uIGZhaWwgYWx0aG91Z2ggZnJlZSBwYWdlcyBlbm91Z2guPGJyPiZndDsmZ3Q7IDxicj4mZ3Q7
Jmd0OyBXZSBjaGVja2VkIHRoaXMgYnkgcmFuZG9tIHRlc3Qgb24gbXkgdGFyZ2V0KDhHQiBSQU0p
Ljxicj4mZ3Q7Jmd0OyA8YnI+Jmd0OyZndDsgJm5ic3A7QmluZGVyOjYyMThfMjogcGFnZSBhbGxv
Y2F0aW9uIGZhaWx1cmU6IG9yZGVyOjAsIG1vZGU6MHgxNDIwMGNhKEdGUF9ISUdIVVNFUl9NT1ZB
QkxFKSwgbm9kZW1hc2s9KG51bGwpPGJyPiZndDsmZ3Q7ICZuYnNwO0JpbmRlcjo2MjE4XzIgY3B1
c2V0PWJhY2tncm91bmQgbWVtc19hbGxvd2VkPTA8YnI+Jmd0Ozxicj4mZ3Q7SG93IGNvbWUgdGhp
cyBvcmRlci0wIHNsZWVwYWJsZSBhbGxvY2F0aW9uIGZhaWxzPyBUaGUgdXBzdHJlYW0ga2VybmVs
PGJyPiZndDtkb2Vzbid0IGZhaWwgdGhvc2UgYWxsb2NhdGlvbnMgdW5sZXNzIHRoZSBwcm9jZXNz
IGNvbnRleHQgaXMga2lsbGVkIGJ5PGJyPiZndDt0aGUgb29tIGtpbGxlci48L3A+PHA+PHNwYW4g
c3R5bGU9J2NvbG9yOiByZ2IoMCwgMCwgMCk7IGZvbnQtZmFtaWx5OiAiTWFsZ3VuIEdvdGhpYyIs
IuunkeydgCDqs6DrlJUiOyBmb250LXNpemU6IDEwcHQ7Jz48L3NwYW4+PC9wPjxwPjxzcGFuIHN0
eWxlPSdjb2xvcjogcmdiKDAsIDAsIDApOyBmb250LWZhbWlseTogIk1hbGd1biBHb3RoaWMiLCLr
p5HsnYAg6rOg65SVIjsgZm9udC1zaXplOiAxMHB0Oyc+TW9zdCBjYWxsdGFja3MgYXJlIHpzbWFs
bG9jLCBhcyBzaG93biBiZWxvdy48L3NwYW4+PC9wPjxwPjxzcGFuIHN0eWxlPSdjb2xvcjogcmdi
KDAsIDAsIDApOyBmb250LWZhbWlseTogIk1hbGd1biBHb3RoaWMiLCLrp5HsnYAg6rOg65SVIjsg
Zm9udC1zaXplOiAxMHB0Oyc+Jm5ic3A7Q2FsbCB0cmFjZTo8YnI+Jm5ic3A7IGR1bXBfYmFja3Ry
YWNlKzB4MC8weDFmMDxicj4mbmJzcDsgc2hvd19zdGFjaysweDE4LzB4MjA8YnI+Jm5ic3A7IGR1
bXBfc3RhY2srMHhjNC8weDEwMDxicj4mbmJzcDsgd2Fybl9hbGxvYysweDEwMC8weDE5ODxicj4m
bmJzcDsgX19hbGxvY19wYWdlc19ub2RlbWFzaysweDExNmMvMHgxMTg4PGJyPiZuYnNwOyBkb19z
d2FwX3BhZ2UrMHgxMGMvMHg2ZjA8YnI+Jm5ic3A7IGhhbmRsZV9wdGVfZmF1bHQrMHgxMmMvMHhm
ZTA8YnI+Jm5ic3A7IGhhbmRsZV9tbV9mYXVsdCsweDFkMC8weDMyODxicj4mbmJzcDsgZG9fcGFn
ZV9mYXVsdCsweDJhMC8weDNlMDxicj4mbmJzcDsgZG9fdHJhbnNsYXRpb25fZmF1bHQrMHg0NC8w
eGE4PGJyPiZuYnNwOyBkb19tZW1fYWJvcnQrMHg0Yy8weGQwPGJyPiZuYnNwOyBlbDFfZGErMHgy
NC8weDg0PGJyPiZuYnNwOyBfX2FyY2hfY29weV90b191c2VyKzB4NWMvMHgyMjA8YnI+Jm5ic3A7
IGJpbmRlcl9pb2N0bCsweDIwYy8weDc0MDxicj4mbmJzcDsgY29tcGF0X1N5U19pb2N0bCsweDEy
OC8weDI0ODxicj4mbmJzcDsgX19zeXNfdHJhY2VfcmV0dXJuKzB4MC8weDQ8YnI+PGJyPiZndDs8
YnI+Jmd0O0Fsc28gcGxlYXNlIG5vdGUgdGhhdCBhdG9taWMgcmVzZXJ2ZXMgYXJlIHJlbGVhc2Vk
IHdoZW4gdGhlIG1lbW9yeTxicj4mZ3Q7cHJlc3N1cmUgaXMgaGlnaCBhbmQgd2UgY2Fubm90IHJl
Y2xhaW0gYW55IG90aGVyIG1lbW9yeS4gSGF2ZSBhIGxvb2sgYXQ8YnI+Jmd0O3VucmVzZXJ2ZV9o
aWdoYXRvbWljX3BhZ2VibG9jayBjYWxsZWQgZnJvbSBzaG91bGRfcmVjbGFpbV9yZXRyeS48L3Nw
YW4+PC9wPjxwPjxicj48L3A+PHA+SSZuYnNwO2tub3cgd2hhdCB5b3Ugc2FpZC4gSG93ZXZlciwg
d2hhdCBJIG1lbnRpb25lZCBpcyBub3QgdGhlIGVmZmljaWVuY3kgb2YgdGhhdCBoaWdoYXRvbWlj
IGJsb2NrLDxicj50aGlzIGlzIHRvIHJlZHVjZSBhbGxvY2F0aW9uIGZhaWwgdGhyb3VnaCBtb3Jl
IGFjY3VyYXRlIHdhdGVybWFyayBjYWxjdWxhdGlvbiB1c2luZzwvcD48cD50aGUgcmVtYWluaW5n
IHBhZ2VzIG9mIGhpZ2hhdG9taWMgZm9yIG5vbi1hdG9taWMgYWxsb2NhdGlvbi48L3A+PHA+PHNw
YW4gc3R5bGU9J2NvbG9yOiByZ2IoMCwgMCwgMCk7IGZvbnQtZmFtaWx5OiAiTWFsZ3VuIEdvdGhp
YyIsIuunkeydgCDqs6DrlJUiOyBmb250LXNpemU6IDEwcHQ7Jz4oT2YgY291cnNlIGV2ZW4gaWYg
d2F0ZXJtYXJrIGlzIGNvcnJlY3QgYWZ0ZXIgc2hvdWxkX3JlY2xhaW1fcmV0cnkoKSw8L3NwYW4+
PC9wPjxwPjxzcGFuIHN0eWxlPSdjb2xvcjogcmdiKDAsIDAsIDApOyBmb250LWZhbWlseTogIk1h
bGd1biBHb3RoaWMiLCLrp5HsnYAg6rOg65SVIjsgZm9udC1zaXplOiAxMHB0Oyc+77u/PC9zcGFu
PjxzcGFuIHN0eWxlPSdjb2xvcjogcmdiKDAsIDAsIDApOyBmb250LWZhbWlseTogIk1hbGd1biBH
b3RoaWMiLCLrp5HsnYAg6rOg65SVIjsgZm9udC1zaXplOiAxMHB0Oyc+SW4gdGhlIGNhc2Ugb2Yg
UEZfTUVNQUxMT0MgYW5kIF9fR0ZQX05PUkVUUlksIDxzcGFuIHN0eWxlPSdjb2xvcjogcmdiKDAs
IDAsIDApOyBmb250LWZhbWlseTogIk1hbGd1biBHb3RoaWMiLCLrp5HsnYAg6rOg65SVIjsgZm9u
dC1zaXplOiAxMHB0Oyc+aXQgd2lsbCBmYWlsIGRlc3BpdGUgYmVpbmcgYWJsZSB0byBhbGxvY2F0
ZSBmcmVlIHBhZ2VzLik8L3NwYW4+PC9zcGFuPjwvcD48cD48c3BhbiBzdHlsZT0nY29sb3I6IHJn
YigwLCAwLCAwKTsgZm9udC1mYW1pbHk6ICJNYWxndW4gR290aGljIiwi66eR7J2AIOqzoOuUlSI7
IGZvbnQtc2l6ZTogMTBwdDsnPjxicj48L3NwYW4+PC9wPjxwPjxzcGFuIHN0eWxlPSdjb2xvcjog
cmdiKDAsIDAsIDApOyBmb250LWZhbWlseTogIk1hbGd1biBHb3RoaWMiLCLrp5HsnYAg6rOg65SV
IjsgZm9udC1zaXplOiAxMHB0Oyc+SW4gb3RoZXIgd29yZHMsIEkgdGhvdWdodCBpdCB3b3VsZCBi
ZSByaWdodCB0byBzdWJ0cmFjdCB0aGUgcmVtYWluaW5nIGZyZWUgYW1vdW50PC9zcGFuPjwvcD48
cD48c3BhbiBzdHlsZT0nY29sb3I6IHJnYigwLCAwLCAwKTsgZm9udC1mYW1pbHk6ICJNYWxndW4g
R290aGljIiwi66eR7J2AIOqzoOuUlSI7IGZvbnQtc2l6ZTogMTBwdDsnPm9mIGhpZ2hhdG9taWMg
ZnJvbSB0aGUgaGlnaGF0b21pYyBwYWdlLiBJbiB0aGUgc2FtZSB0ZXN0LCBhbGxvY2F0aW9uIGZh
aWx1cmUgaXMgcmVkdWNlZC48YnI+PC9zcGFuPjwvcD48cD48c3BhbiBzdHlsZT0nY29sb3I6IHJn
YigwLCAwLCAwKTsgZm9udC1mYW1pbHk6ICJNYWxndW4gR290aGljIiwi66eR7J2AIOqzoOuUlSI7
IGZvbnQtc2l6ZTogMTBwdDsnPjxicj48L3NwYW4+PC9wPjxwPjxzcGFuIHN0eWxlPSdjb2xvcjog
cmdiKDAsIDAsIDApOyBmb250LWZhbWlseTogIk1hbGd1biBHb3RoaWMiLCLrp5HsnYAg6rOg65SV
IjsgZm9udC1zaXplOiAxMHB0Oyc+VGVzdCBlbnZpcm9ubWVudDo8YnI+LSBCb2FyZDogU0RNNDUw
LCA0R0IgUkFNLDxicj4tIFBsYXRmb3JtOiBBbmRyb2lkIFAgT3M8L3NwYW4+PC9wPjxwPjxzcGFu
IHN0eWxlPSdjb2xvcjogcmdiKDAsIDAsIDApOyBmb250LWZhbWlseTogIk1hbGd1biBHb3RoaWMi
LCLrp5HsnYAg6rOg65SVIjsgZm9udC1zaXplOiAxMHB0Oyc+VGVzdCBtZXRob2Q6PGJyPi0gNjAg
YXBwcyBpbnN0YWxsZWQ8L3NwYW4+PC9wPjxwPjxzcGFuIHN0eWxlPSdjb2xvcjogcmdiKDAsIDAs
IDApOyBmb250LWZhbWlseTogIk1hbGd1biBHb3RoaWMiLCLrp5HsnYAg6rOg65SVIjsgZm9udC1z
aXplOiAxMHB0Oyc+LSBTYW1lIHBhdHRlcm4gdGVzdCBzY3JpcHQuPC9zcGFuPjwvcD48cD48c3Bh
biBzdHlsZT0nY29sb3I6IHJnYigwLCAwLCAwKTsgZm9udC1mYW1pbHk6ICJNYWxndW4gR290aGlj
Iiwi66eR7J2AIOqzoOuUlSI7IGZvbnQtc2l6ZTogMTBwdDsnPlJlc3VsdDo8YnI+LSBiZWZvcmU6
IDc2IHBhZ2UgYWxsb2NhdGlvbiBmYWlsPGJyPi0gYWZ0ZXI6IHplcm88L3NwYW4+PC9wPjxwPjxz
cGFuIHN0eWxlPSdjb2xvcjogcmdiKDAsIDAsIDApOyBmb250LWZhbWlseTogIk1hbGd1biBHb3Ro
aWMiLCLrp5HsnYAg6rOg65SVIjsgZm9udC1zaXplOiAxMHB0Oyc+PGJyPjwvc3Bhbj48L3A+PHA+
PHNwYW4gc3R5bGU9J2NvbG9yOiByZ2IoMCwgMCwgMCk7IGZvbnQtZmFtaWx5OiAiTWFsZ3VuIEdv
dGhpYyIsIuunkeydgCDqs6DrlJUiOyBmb250LXNpemU6IDEwcHQ7Jz5UaGFua3M8L3NwYW4+PC9w
PjxwPjxzcGFuIHN0eWxlPSdjb2xvcjogcmdiKDAsIDAsIDApOyBmb250LWZhbWlseTogIk1hbGd1
biBHb3RoaWMiLCLrp5HsnYAg6rOg65SVIjsgZm9udC1zaXplOiAxMHB0Oyc+U2FuZ3dvbzwvc3Bh
bj48L3A+PC9ib2R5PjwvaHRtbD4=

