From: Joerg Roedel <joro-zLv9SwRftAIdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 1/6] mmput: use notifier chain to call subsystem exit
	handler.
Date: Tue, 1 Jul 2014 13:00:18 +0200
Message-ID: <20140701110018.GH26537@8bytes.org>
References: <1403920822-14488-1-git-send-email-j.glisse@gmail.com>
	<1403920822-14488-2-git-send-email-j.glisse@gmail.com>
	<019CCE693E457142B37B791721487FD91806B836@storexdag01.amd.com>
	<20140630154042.GD26537@8bytes.org>
	<20140630160604.GF1956@gmail.com>
	<20140630181623.GE26537@8bytes.org>
	<20140630183556.GB3280@gmail.com>
	<20140701091535.GF26537@8bytes.org>
	<019CCE693E457142B37B791721487FD91806DD8B@storexdag01.amd.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Return-path: <iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <019CCE693E457142B37B791721487FD91806DD8B-0nO7ALo/ziwxlywnonMhLEEOCMrvLtNR@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/iommu>,
	<mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/iommu/>
List-Post: <mailto:iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/iommu>,
	<mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Gabbay, Oded" <Oded.Gabbay-5C7GfCeVMHo@public.gmane.org>
Cc: Sherry Cheung <SCheung-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>, "linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org" <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>, "hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, Jerome Glisse <j.glisse-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, "aarcange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <aarcange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Jatin Kumar <jakumar-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>, Lucien Dunning <ldunning-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>, "mgorman-l3A5Bk7waGM@public.gmane.org" <mgorman-l3A5Bk7waGM@public.gmane.org>, "jweiner-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <jweiner-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Subhash Gutti <sgutti-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>, "riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "Bridgman,
	John" <John.Bridgman-5C7GfCeVMHo@public.gmane.org>, John Hubbard <jhubbard-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>, Mark Hairgrove <mhairgrove-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>, Cameron Buschardt <cabuschardt-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>, "peterz-hDdKplPs4pWWVfeAwA7xHQ@public.gmane.org" <peterz-hDdKplPs4pWWVfeAwA7xHQ@public.gmane.org>, Duncan Poole <dpoole-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>, "Cornwall,
	Jay" <Jay.Cornwall-5C7GfCeVMHo@public.gmane.org>, "Lewycky, Andrew" <Andrew.Lewycky-5C7GfCeVMHo@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>A
List-Id: linux-mm.kvack.org

T24gVHVlLCBKdWwgMDEsIDIwMTQgYXQgMDk6Mjk6NDlBTSArMDAwMCwgR2FiYmF5LCBPZGVkIHdy
b3RlOgo+IEluIHRoZSBLRkQsIHdlIG5lZWQgdG8gbWFpbnRhaW4gYSBub3Rpb24gb2YgZWFjaCBj
b21wdXRlIHByb2Nlc3MuCj4gVGhlcmVmb3JlLCB3ZSBoYXZlIGFuIG9iamVjdCBjYWxsZWQgImtm
ZF9wcm9jZXNzIiB0aGF0IGlzIGNyZWF0ZWQgZm9yCj4gZWFjaCBwcm9jZXNzIHRoYXQgdXNlcyB0
aGUgS0ZELiBOYXR1cmFsbHksIHdlIG5lZWQgdG8gYmUgYWJsZSB0byB0cmFjawo+IHRoZSBwcm9j
ZXNzJ3Mgc2h1dGRvd24gaW4gb3JkZXIgdG8gcGVyZm9ybSBjbGVhbnVwIG9mIHRoZSByZXNvdXJj
ZXMgaXQKPiB1c2VzIChjb21wdXRlIHF1ZXVlcywgdmlydHVhbCBhZGRyZXNzIHNwYWNlLCBncHUg
bG9jYWwgbWVtb3J5Cj4gYWxsb2NhdGlvbnMsIGV0Yy4pLgoKSWYgaXQgaXMgb25seSB0aGF0LCB5
b3UgY2FuIGFsc28gdXNlIHRoZSB0YXNrX2V4aXQgbm90aWZpZXIgYWxyZWFkeSBpbgp0aGUga2Vy
bmVsLgoKPiBUbyBlbmFibGUgdGhpcyB0cmFja2luZyBtZWNoYW5pc20sIHdlIGRlY2lkZWQgdG8g
YXNzb2NpYXRlIHRoZQo+IGtmZF9wcm9jZXNzIHdpdGggbW1fc3RydWN0IHRvIGVuc3VyZSB0aGF0
IGEga2ZkX3Byb2Nlc3Mgb2JqZWN0IGhhcwo+IGV4YWN0bHkgdGhlIHNhbWUgbGlmZXNwYW4gYXMg
dGhlIHByb2Nlc3MgaXQgcmVwcmVzZW50cy4gV2UgcHJlZmVycmVkIHRvCj4gdXNlIHRoZSBtbV9z
dHJ1Y3QgYW5kIG5vdCBhIGZpbGUgZGVzY3JpcHRpb24gYmVjYXVzZSB1c2luZyBhIGZpbGUKPiBk
ZXNjcmlwdG9yIHRvIHRyYWNrIOKAnHByb2Nlc3PigJ0gc2h1dGRvd24gaXMgd3JvbmcgaW4gdHdv
IHdheXM6Cj4gCj4gKiBUZWNobmljYWw6IGZpbGUgZGVzY3JpcHRvcnMgY2FuIGJlIHBhc3NlZCB0
byB1bnJlbGF0ZWQgcHJvY2Vzc2VzIHVzaW5nCj4gQUZfVU5JWCBzb2NrZXRzLiBUaGlzIG1lYW5z
IHRoYXQgYSBwcm9jZXNzIGNhbiBleGl0IHdoaWxlIHRoZSBmaWxlIHN0YXlzCj4gb3Blbi4gRXZl
biBpZiB3ZSBpbXBsZW1lbnQgdGhpcyDigJxjb3JyZWN0bHnigJ0gaS5lLiBob2xkaW5nIHRoZSBh
ZGRyZXNzCj4gc3BhY2UgJiBwYWdlIHRhYmxlcyBhbGl2ZSB1bnRpbCB0aGUgZmlsZSBpcyBmaW5h
bGx5IHJlbGVhc2VkLCBpdOKAmXMKPiByZWFsbHkgZG9kZ3kuCgpObywgaXRzIG5vdCBpbiB0aGlz
IGNhc2UuIFRoZSBmaWxlIGRlc2NyaXB0b3IgaXMgdXNlZCB0byBjb25uZWN0IGEKcHJvY2VzcyBh
ZGRyZXNzIHNwYWNlIHdpdGggYSBkZXZpY2UgY29udGV4dC4gVGh1cyB3aXRob3V0IHRoZSBtYXBw
aW5ncwp0aGUgZmlsZS1kZXNjcmlwdG9yIGlzIHVzZWxlc3MgYW5kIHRoZSBtYXBwaW5ncyBzaG91
bGQgc3RheSBpbi10YWN0CnVudGlsIHRoZSBmZCBpcyBjbG9zZWQuCgpJdCB3b3VsZCBiZSBhIHZl
cnkgYmFkIHNlbWFudGljIGZvciB1c2Vyc3BhY2UgaWYgYSBmZCB0aGF0IGlzIHBhc3NlZCBvbgpm
YWlscyBvbiB0aGUgb3RoZXIgc2lkZSBiZWNhdXNlIHRoZSBzZW5kaW5nIHByb2Nlc3MgZGllZC4K
CgoJSm9lcmcKCgpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
Xwppb21tdSBtYWlsaW5nIGxpc3QKaW9tbXVAbGlzdHMubGludXgtZm91bmRhdGlvbi5vcmcKaHR0
cHM6Ly9saXN0cy5saW51eGZvdW5kYXRpb24ub3JnL21haWxtYW4vbGlzdGluZm8vaW9tbXU=
